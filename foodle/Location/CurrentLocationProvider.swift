import CoreLocation
import Foundation
import MapKit

enum CurrentLocationError: LocalizedError {
    case permissionDenied
    case unableToDetermineLocation
    case unableToResolvePlaceName
    case requestInProgress

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied. Please allow location access to use Surprise Me."
        case .unableToDetermineLocation:
            return "Could not determine your current location. Please try again."
        case .unableToResolvePlaceName:
            return "Could not determine your city and state from current location."
        case .requestInProgress:
            return "Location request already in progress."
        }
    }
}

@MainActor
final class CurrentLocationProvider: NSObject {
    private let manager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestCurrentCoordinate() async throws -> CLLocationCoordinate2D {
        guard locationContinuation == nil else {
            throw CurrentLocationError.requestInProgress
        }

        try await ensureAuthorization()

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    func requestCurrentLocationQuery() async throws -> String {
        let coordinate = try await requestCurrentCoordinate()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let query = try await reverseGeocodeLocationQuery(location: location)

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return trimmed
        }

        throw CurrentLocationError.unableToResolvePlaceName
    }

    private func reverseGeocodeLocationQuery(location: CLLocation) async throws -> String {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw CurrentLocationError.unableToResolvePlaceName
        }

        return try await withCheckedThrowingContinuation { continuation in
            request.getMapItems { mapItems, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let mapItem = mapItems?.first else {
                    continuation.resume(throwing: CurrentLocationError.unableToResolvePlaceName)
                    return
                }

                let query =
                    mapItem.addressRepresentations?.cityWithContext(.short)
                    ?? mapItem.addressRepresentations?.cityName
                    ?? mapItem.address?.shortAddress
                    ?? mapItem.address?.fullAddress

                if let query, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continuation.resume(returning: query)
                } else {
                    continuation.resume(throwing: CurrentLocationError.unableToResolvePlaceName)
                }
            }
        }
    }

    private func ensureAuthorization() async throws {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .notDetermined:
            try await withCheckedThrowingContinuation { continuation in
                authorizationContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        case .denied, .restricted:
            throw CurrentLocationError.permissionDenied
        @unknown default:
            throw CurrentLocationError.unableToDetermineLocation
        }
    }
}

extension CurrentLocationProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authorizationContinuation else { return }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            authorizationContinuation = nil
            continuation.resume()
        case .denied, .restricted:
            authorizationContinuation = nil
            continuation.resume(throwing: CurrentLocationError.permissionDenied)
        case .notDetermined:
            break
        @unknown default:
            authorizationContinuation = nil
            continuation.resume(throwing: CurrentLocationError.unableToDetermineLocation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil

        guard let coordinate = locations.last?.coordinate else {
            continuation.resume(throwing: CurrentLocationError.unableToDetermineLocation)
            return
        }

        continuation.resume(returning: coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil

        let nsError = error as NSError
        if nsError.domain == kCLErrorDomain, nsError.code == CLError.denied.rawValue {
            continuation.resume(throwing: CurrentLocationError.permissionDenied)
        } else {
            continuation.resume(throwing: CurrentLocationError.unableToDetermineLocation)
        }
    }
}

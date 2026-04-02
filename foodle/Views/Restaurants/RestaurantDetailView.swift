import MapKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct RestaurantDetailView: View {
    let restaurantID: String
    @StateObject private var viewModel = RestaurantDetailViewModel()
    @State private var showYelpAlert = false
    @State private var showWebsiteAlert = false
    @State private var showPhoneAlert = false

    var body: some View {
        ZStack {
            GlassBackgroundView()

            ScrollView {
                VStack(spacing: 14) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 20)
                    }

                    if let restaurant = viewModel.restaurant {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(restaurant.name)
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)

                                RatingStarsView(rating: restaurant.rating)

                                if let price = restaurant.price {
                                    Text(price)
                                        .foregroundStyle(.white.opacity(0.88))
                                }

                                let categories = restaurant.categories.map(\.title).joined(separator: ", ")
                                if !categories.isEmpty {
                                    Text(categories)
                                        .foregroundStyle(.white.opacity(0.88))
                                }

                                if let phone = restaurant.displayPhone, !phone.isEmpty {
                                    if let phoneURL = phoneLinkURL(from: phone) {
                                        actionRow(
                                            title: phone,
                                            systemImage: "phone.fill"
                                        ) {
                                            openExternalURL(phoneURL, alert: .phone)
                                        }
                                    } else {
                                        Text(phone)
                                            .foregroundStyle(.white.opacity(0.88))
                                    }
                                }

                                if let website = restaurant.websiteURL,
                                   let websiteURL = normalizedExternalURL(from: website) {
                                    actionRow(
                                        title: website,
                                        systemImage: "safari.fill"
                                    ) {
                                        openExternalURL(websiteURL, alert: .website)
                                    }
                                } else if let website = restaurant.websiteURL, !website.isEmpty {
                                    Text(website)
                                        .foregroundStyle(.white.opacity(0.88))
                                }

                                if let yelpURL = yelpDestinationURL(for: restaurant) {
                                    actionRow(
                                        title: "View on Yelp",
                                        systemImage: "star.bubble.fill"
                                    ) {
                                        openExternalURL(yelpURL, alert: .yelp)
                                    }
                                } else if let yelpURL = restaurant.yelpURL, !yelpURL.isEmpty {
                                    Text("Yelp link unavailable")
                                        .foregroundStyle(.blue)
                                }

                                RemoteImageView(urlString: restaurant.imageURL, height: 220)
                                    .allowsHitTesting(false)

                                let address = restaurant.location?.displayAddress.joined(separator: ", ") ?? ""
                                if !address.isEmpty {
                                    if let mapsURL = mapsPinURL(for: restaurant, address: address) {
                                        Link(destination: mapsURL) {
                                            Text(address)
                                                .font(.footnote)
                                                .underline()
                                        }
                                        .foregroundStyle(.blue)
                                        .padding(.top, 4)
                                    } else {
                                        Text(address)
                                            .font(.footnote)
                                            .foregroundStyle(.white.opacity(0.88))
                                            .padding(.top, 4)
                                    }
                                }

                            }
                        }

                        if let latitude = restaurant.coordinates?.latitude,
                           let longitude = restaurant.coordinates?.longitude {
                            Map(initialPosition: .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            ))) {
                                Marker(restaurant.name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            }
                            .frame(height: 220)
                            .allowsHitTesting(false)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(.white.opacity(0.22), lineWidth: 0.8)
                            )
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        GlassCard {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Restaurant")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await viewModel.load(id: restaurantID)
        }
        .alert("Can't Open Yelp", isPresented: $showYelpAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The Yelp page could not be opened.")
        }
        .alert("Can't Open Website", isPresented: $showWebsiteAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The website could not be opened.")
        }
        .alert("Can't Call Number", isPresented: $showPhoneAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The phone number could not be opened.")
        }
    }

    private func normalizedExternalURL(from value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let withScheme: String
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            withScheme = trimmed
        } else {
            withScheme = "https://\(trimmed)"
        }

        if let direct = URL(string: withScheme), direct.scheme != nil {
            return direct
        }

        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%")
        if let encoded = withScheme.addingPercentEncoding(withAllowedCharacters: allowed) {
            return URL(string: encoded)
        }

        return nil
    }

    private func phoneLinkURL(from value: String) -> URL? {
        let allowed = CharacterSet(charactersIn: "+0123456789")
        let compact = String(value.unicodeScalars.filter { allowed.contains($0) })
        guard !compact.isEmpty else { return nil }
        return URL(string: "tel://\(compact)")
    }

    private func yelpDestinationURL(for restaurant: Restaurant) -> URL? {
        if let rawURL = restaurant.yelpURL?.trimmingCharacters(in: .whitespacesAndNewlines),
           !rawURL.isEmpty,
           let directURL = directWebURL(from: rawURL) {
            return directURL
        }

        let locationText = restaurant.location?.displayAddress.joined(separator: ", ")
            ?? [restaurant.location?.city, restaurant.location?.state]
                .compactMap { $0 }
                .joined(separator: ", ")

        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.yelp.com"
        components.path = "/search"
        components.queryItems = [
            URLQueryItem(name: "find_desc", value: restaurant.name),
            URLQueryItem(name: "find_loc", value: locationText)
        ]
        return components.url
    }

    private func directWebURL(from value: String) -> URL? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let candidates: [String]
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            candidates = [trimmed]
        } else {
            candidates = ["https://\(trimmed)"]
        }

        for candidate in candidates {
            if let url = URL(string: candidate), let scheme = url.scheme?.lowercased(),
               scheme == "http" || scheme == "https" {
                return url
            }
        }

        return nil
    }

    private func mapsPinURL(for restaurant: Restaurant, address: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"

        var items: [URLQueryItem] = []

        if let latitude = restaurant.coordinates?.latitude,
           let longitude = restaurant.coordinates?.longitude {
            items.append(URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"))
            items.append(URLQueryItem(name: "q", value: restaurant.name))
        } else {
            items.append(URLQueryItem(name: "q", value: "\(restaurant.name), \(address)"))
        }

        components.queryItems = items
        return components.url
    }

    private func openExternalURL(_ url: URL, alert: ExternalAlert) {
        #if canImport(UIKit)
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                showAlert(alert)
            }
        }
        #else
        showAlert(alert)
        #endif
    }

    private func showAlert(_ alert: ExternalAlert) {
        switch alert {
        case .yelp:
            showYelpAlert = true
        case .website:
            showWebsiteAlert = true
        case .phone:
            showPhoneAlert = true
        }
    }

    @ViewBuilder
    private func actionRow(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.footnote.weight(.semibold))
                Text(title)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.blue)
        .background(Color.black.opacity(0.001))
        .zIndex(10)
    }
}

private enum ExternalAlert {
    case yelp
    case website
    case phone
}

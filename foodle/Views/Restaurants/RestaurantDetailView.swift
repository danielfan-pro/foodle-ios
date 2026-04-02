import MapKit
import SwiftUI

struct RestaurantDetailView: View {
    let restaurantID: String
    @StateObject private var viewModel = RestaurantDetailViewModel()

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
                                        Link(phone, destination: phoneURL)
                                            .foregroundStyle(.blue)
                                    } else {
                                        Text(phone)
                                            .foregroundStyle(.white.opacity(0.88))
                                    }
                                }

                                if let website = restaurant.websiteURL,
                                   let websiteURL = normalizedExternalURL(from: website) {
                                    Link(destination: websiteURL) {
                                        Text(website)
                                    }
                                    .foregroundStyle(.blue)
                                } else if let website = restaurant.websiteURL, !website.isEmpty {
                                    Text(website)
                                        .foregroundStyle(.white.opacity(0.88))
                                }

                                if let yelpURL = restaurant.yelpURL,
                                   let normalizedYelpURL = normalizedExternalURL(from: yelpURL) {
                                    Link("View on Yelp", destination: normalizedYelpURL)
                                    .foregroundStyle(.blue)
                                } else if let yelpURL = restaurant.yelpURL, !yelpURL.isEmpty {
                                    Text("Yelp link unavailable")
                                        .foregroundStyle(.blue)
                                }

                                RemoteImageView(urlString: restaurant.imageURL, height: 220)

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
}

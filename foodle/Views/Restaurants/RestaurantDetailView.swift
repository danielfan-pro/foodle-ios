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
                                    Text(phone)
                                        .foregroundStyle(.white.opacity(0.88))
                                }

                                if let website = restaurant.websiteURL, !website.isEmpty {
                                    Link(destination: normalizedURL(from: website)) {
                                        Text(website)
                                            .foregroundStyle(.blue)
                                    }
                                }

                                if let yelpURL = restaurant.yelpURL, let url = URL(string: yelpURL) {
                                    Link("View on Yelp", destination: url)
                                        .foregroundStyle(.blue)
                                }

                                RemoteImageView(urlString: restaurant.imageURL, height: 220)

                                let address = restaurant.location?.displayAddress.joined(separator: ", ") ?? ""
                                if !address.isEmpty {
                                    Text(address)
                                        .font(.footnote)
                                        .foregroundStyle(.white.opacity(0.88))
                                        .padding(.top, 4)
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

    private func normalizedURL(from value: String) -> URL {
        if let direct = URL(string: value), direct.scheme != nil {
            return direct
        }
        return URL(string: "https://\(value)") ?? URL(string: "https://www.yelp.com") ?? URL(fileURLWithPath: "/")
    }
}

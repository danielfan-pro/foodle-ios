import SwiftUI

struct RestaurantSearchView: View {
    @StateObject private var viewModel = RestaurantSearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackgroundView()

                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            VStack(spacing: 12) {
                                Text("Find Restaurants")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)

                                TextField("address, city, state or zip", text: $viewModel.location)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                TextField("category (pizza, sandwich, etc)", text: $viewModel.item)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                HStack(spacing: 10) {
                                    Button("Search") {
                                        Task { await viewModel.search() }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.cyan)

                                    Button("Reset") {
                                        viewModel.reset()
                                        viewModel.location = ""
                                        viewModel.item = ""
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.white)
                                }

                                if let errorMessage = viewModel.errorMessage {
                                    Text(errorMessage)
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        }

                        if let featured = viewModel.featured {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Featured Recommendation")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.95))

                                NavigationLink {
                                    RestaurantDetailView(restaurantID: featured.id)
                                } label: {
                                    RestaurantRowCard(restaurant: featured)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if !viewModel.others.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Alternative Recommendations")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.95))

                                ForEach(viewModel.others) { restaurant in
                                    NavigationLink {
                                        RestaurantDetailView(restaurantID: restaurant.id)
                                    } label: {
                                        RestaurantRowCard(restaurant: restaurant)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Restaurants")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

private struct RestaurantRowCard: View {
    let restaurant: Restaurant

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                RatingStarsView(rating: restaurant.rating)

                if let price = restaurant.price {
                    Text(price)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.86))
                }

                let categories = restaurant.categories.map(\.title).joined(separator: ", ")
                if !categories.isEmpty {
                    Text(categories)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.86))
                        .padding(.bottom, 2)
                }

                RemoteImageView(urlString: restaurant.imageURL)
            }
        }
    }
}

#Preview {
    RestaurantSearchView()
}

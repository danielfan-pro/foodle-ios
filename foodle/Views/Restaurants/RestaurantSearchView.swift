import SwiftUI

struct RestaurantSearchView: View {
    private enum FocusField {
        case location
        case item
    }

    @StateObject private var viewModel = RestaurantSearchViewModel()
    @FocusState private var focusedField: FocusField?

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
                                    .foregroundStyle(.primary)

                                TextField("address, city, state or zip", text: $viewModel.location)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .submitLabel(.search)
                                    .onSubmit {
                                        focusedField = nil
                                        Task { await viewModel.search() }
                                    }
                                    .focused($focusedField, equals: .location)
                                    .padding(12)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                TextField("category (pizza, sandwich, etc)", text: $viewModel.item)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .submitLabel(.search)
                                    .onSubmit {
                                        focusedField = nil
                                        Task { await viewModel.search() }
                                    }
                                    .focused($focusedField, equals: .item)
                                    .padding(12)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                HStack(spacing: 10) {
                                    Button("Search") {
                                        Task { await viewModel.search() }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)

                                    Button("Reset") {
                                        viewModel.reset()
                                        viewModel.location = ""
                                        viewModel.item = ""
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.primary)
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
                                .tint(.primary)
                        }

                        if let featured = viewModel.featured {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Featured Recommendation")
                                    .font(.headline)
                                    .foregroundStyle(.primary)

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
                                    .foregroundStyle(.primary)

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
                    .foregroundStyle(.primary)

                RatingStarsView(rating: restaurant.rating)

                if let price = restaurant.price {
                    Text(price)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                let categories = restaurant.categories.map(\.title).joined(separator: ", ")
                if !categories.isEmpty {
                    Text(categories)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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

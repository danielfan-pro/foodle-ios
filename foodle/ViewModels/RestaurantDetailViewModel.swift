import Foundation

@MainActor
final class RestaurantDetailViewModel: ObservableObject {
    @Published var restaurant: Restaurant?
    @Published var errorMessage: String?
    @Published var isLoading = false

    func load(id: String) async {
        isLoading = true
        errorMessage = nil

        do {
            var baseRestaurant = try await APIClient.shared.getRestaurant(id: id)
            restaurant = baseRestaurant

            if baseRestaurant.websiteURL == nil {
                let website = try await APIClient.shared.getRestaurantWebsite(id: id)
                baseRestaurant = Restaurant(
                    id: baseRestaurant.id,
                    name: baseRestaurant.name,
                    imageURL: baseRestaurant.imageURL,
                    price: baseRestaurant.price,
                    rating: baseRestaurant.rating,
                    categories: baseRestaurant.categories,
                    displayPhone: baseRestaurant.displayPhone,
                    websiteURL: website,
                    yelpURL: baseRestaurant.yelpURL,
                    location: baseRestaurant.location,
                    coordinates: baseRestaurant.coordinates
                )
                restaurant = baseRestaurant
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

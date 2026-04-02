import Foundation

@MainActor
final class RestaurantSearchViewModel: ObservableObject {
    @Published var location = ""
    @Published var item = ""
    @Published var featured: Restaurant?
    @Published var others: [Restaurant] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    var hasResults: Bool {
        featured != nil || !others.isEmpty
    }

    func reset() {
        featured = nil
        others = []
        errorMessage = nil
    }

    func search() async {
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLocation.isEmpty else {
            errorMessage = "Please enter a location."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await APIClient.shared.searchRestaurants(location: trimmedLocation, item: item)
            featured = result.featured
            others = result.others
        } catch {
            featured = nil
            others = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

import Foundation

@MainActor
final class RecipeSearchViewModel: ObservableObject {
    @Published var item = ""
    @Published var featured: Recipe?
    @Published var others: [Recipe] = []
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
        isLoading = true
        errorMessage = nil

        do {
            let result = try await APIClient.shared.searchRecipes(item: item)
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

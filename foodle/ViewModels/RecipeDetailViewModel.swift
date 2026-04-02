import Foundation
import Combine

@MainActor
final class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: Recipe?
    @Published var errorMessage: String?
    @Published var isLoading = false

    func load(id: Int) async {
        isLoading = true
        errorMessage = nil

        do {
            recipe = try await APIClient.shared.getRecipe(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

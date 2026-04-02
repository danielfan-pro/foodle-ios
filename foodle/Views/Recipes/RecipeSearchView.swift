import SwiftUI

struct RecipeSearchView: View {
    @StateObject private var viewModel = RecipeSearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackgroundView()

                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            VStack(spacing: 12) {
                                Text("Find Recipes")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)

                                TextField("category (pizza, pasta, etc)", text: $viewModel.item)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                                HStack(spacing: 10) {
                                    Button("Search") {
                                        Task { await viewModel.search() }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.orange)

                                    Button("Reset") {
                                        viewModel.item = ""
                                        viewModel.reset()
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
                                    RecipeDetailView(recipeID: featured.id)
                                } label: {
                                    RecipeRowCard(recipe: featured)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if !viewModel.others.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Alternative Recommendations")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.95))

                                ForEach(viewModel.others) { recipe in
                                    NavigationLink {
                                        RecipeDetailView(recipeID: recipe.id)
                                    } label: {
                                        RecipeRowCard(recipe: recipe)
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
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct RecipeRowCard: View {
    let recipe: Recipe

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                if let ready = recipe.readyInMinutes {
                    Text("Ready in \(ready) min")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.86))
                }

                RemoteImageView(urlString: recipe.image)
            }
        }
    }
}

#Preview {
    RecipeSearchView()
}

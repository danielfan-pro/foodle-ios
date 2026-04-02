import SwiftUI

struct RecipeSearchView: View {
    @StateObject private var viewModel = RecipeSearchViewModel()
    @FocusState private var isInputFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

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
                                    .foregroundStyle(.primary)

                                TextField("category (pizza, pasta, etc)", text: $viewModel.item)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .submitLabel(.search)
                                    .onSubmit {
                                        isInputFocused = false
                                        Task { await viewModel.search() }
                                    }
                                    .focused($isInputFocused)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(searchFieldBackgroundColor)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(searchFieldBorderColor, lineWidth: 0.8)
                                    )

                                HStack(spacing: 10) {
                                    Button("Search") {
                                        Task { await viewModel.search() }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)

                                    Button("Reset") {
                                        viewModel.item = ""
                                        viewModel.reset()
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
                                    .foregroundStyle(.primary)

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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

private extension RecipeSearchView {
    var searchFieldBackgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.16) : Color.white.opacity(0.85)
    }

    var searchFieldBorderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.24) : Color.black.opacity(0.08)
    }
}

private struct RecipeRowCard: View {
    let recipe: Recipe

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let ready = recipe.readyInMinutes {
                    Text("Ready in \(ready) min")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                RemoteImageView(urlString: recipe.image)
            }
        }
    }
}

#Preview {
    RecipeSearchView()
}

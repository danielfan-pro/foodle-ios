import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    let recipeID: Int
    @StateObject private var viewModel = RecipeDetailViewModel()

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

                    if let recipe = viewModel.recipe {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(recipe.title)
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)

                                RemoteImageView(urlString: recipe.image, height: 220)

                                if let ready = recipe.readyInMinutes {
                                    Text("Ready in \(ready) minutes")
                                        .foregroundStyle(.white.opacity(0.9))
                                }

                                if let servings = recipe.servings {
                                    Text("Servings: \(servings)")
                                        .foregroundStyle(.white.opacity(0.9))
                                }

                                if let summary = recipe.summary,
                                   let attributedSummary = attributedHTML(summary) {
                                    Text(attributedSummary)
                                        .font(.footnote)
                                        .foregroundStyle(.white.opacity(0.88))
                                }

                                if let sourceURL = recipe.sourceURL,
                                   let url = URL(string: sourceURL) {
                                    Link("Read full instructions (external site)", destination: url)
                                        .foregroundStyle(linkColor)
                                        .underline()
                                        .padding(.top, 2)
                                }
                            }
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
        .navigationTitle("Recipe")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            await viewModel.load(id: recipeID)
        }
    }

    private func attributedHTML(_ html: String) -> AttributedString? {
        guard let data = html.data(using: .utf8) else { return nil }
        guard let nsAttributed = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        ) else {
            return nil
        }
        // Strip embedded HTML styling (including hard-to-read link colors in dark mode)
        // and render plain readable text in app-defined colors.
        return AttributedString(nsAttributed.string)
    }
}

private extension RecipeDetailView {
    var linkColor: Color {
        colorScheme == .dark ? Color(red: 0.72, green: 0.90, blue: 1.0) : .blue
    }
}

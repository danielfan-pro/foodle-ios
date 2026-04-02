import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RestaurantSearchView()
                .tabItem {
                    Label("Restaurants", systemImage: "fork.knife")
                }

            RecipeSearchView()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.regularMaterial, for: .tabBar)
    }
}

#Preview {
    ContentView()
}

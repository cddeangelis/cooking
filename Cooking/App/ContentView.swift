import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book.closed")
                }

            MealPlannerView()
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }

            ShoppingListView()
                .tabItem {
                    Label("Shopping", systemImage: "cart")
                }

            TimerListView()
                .tabItem {
                    Label("Timers", systemImage: "timer")
                }
        }
        .tint(Color.accentColor)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}

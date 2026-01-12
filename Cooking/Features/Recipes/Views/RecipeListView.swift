import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.updatedAt, order: .reverse) private var recipes: [Recipe]

    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var showingAddRecipe = false
    @State private var showFavoritesOnly = false

    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(searchText) }

            let matchesCategory = selectedCategory == nil || recipe.category == selectedCategory

            let matchesFavorite = !showFavoritesOnly || recipe.isFavorite

            return matchesSearch && matchesCategory && matchesFavorite
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    emptyState
                } else {
                    recipeList
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes or ingredients")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Toggle("Favorites Only", isOn: $showFavoritesOnly)

                        Divider()

                        Button("All Categories") {
                            selectedCategory = nil
                        }

                        ForEach(Category.allCases) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Label(category.rawValue, systemImage: category.icon)
                            }
                        }
                    } label: {
                        Image(systemName: filterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddRecipe = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                NavigationStack {
                    RecipeEditView(recipe: nil)
                }
            }
        }
    }

    private var filterActive: Bool {
        selectedCategory != nil || showFavoritesOnly
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Recipes Yet", systemImage: "book.closed")
        } description: {
            Text("Add your first recipe to get started!")
        } actions: {
            Button("Add Recipe") {
                showingAddRecipe = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var recipeList: some View {
        List {
            if filteredRecipes.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeRowView(recipe: recipe)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe)
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            let recipe = filteredRecipes[index]
            modelContext.delete(recipe)
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(for: Recipe.self, inMemory: true)
}

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            recipeImage
            recipeInfo
            Spacer()
            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var recipeImage: some View {
        if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: recipe.category.icon)
                        .foregroundStyle(.secondary)
                }
        }
    }

    private var recipeInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.title)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 8) {
                Label(recipe.category.rawValue, systemImage: recipe.category.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let time = recipe.formattedTotalTime {
                    Label(time, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !recipe.summary.isEmpty {
                Text(recipe.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    let recipe = Recipe(
        title: "Spaghetti Carbonara",
        summary: "Classic Italian pasta dish",
        ingredients: [
            Ingredient(name: "Spaghetti", quantity: 1, unit: "lb"),
            Ingredient(name: "Eggs", quantity: 4)
        ],
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        category: .dinner,
        isFavorite: true
    )

    return List {
        RecipeRowView(recipe: recipe)
    }
    .modelContainer(for: Recipe.self, inMemory: true)
}

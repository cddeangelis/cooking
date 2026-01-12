import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var recipe: Recipe

    @State private var showingEditSheet = false
    @State private var showingCookMode = false
    @State private var showingDeleteAlert = false
    @State private var adjustedServings: Int

    init(recipe: Recipe) {
        self.recipe = recipe
        self._adjustedServings = State(initialValue: recipe.servings)
    }

    private var servingMultiplier: Double {
        guard recipe.servings > 0 else { return 1 }
        return Double(adjustedServings) / Double(recipe.servings)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                quickInfoSection
                servingsAdjuster
                ingredientsSection
                instructionsSection

                if !recipe.notes.isEmpty {
                    notesSection
                }
            }
            .padding()
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button {
                        recipe.isFavorite.toggle()
                    } label: {
                        Label(
                            recipe.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: recipe.isFavorite ? "heart.slash" : "heart"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                RecipeEditView(recipe: recipe)
            }
        }
        .fullScreenCover(isPresented: $showingCookMode) {
            CookModeView(recipe: recipe, servingMultiplier: servingMultiplier)
        }
        .alert("Delete Recipe", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(recipe)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete \"\(recipe.title)\"? This action cannot be undone.")
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if !recipe.summary.isEmpty {
                Text(recipe.summary)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Button {
                showingCookMode = true
            } label: {
                Label("Start Cooking", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private var quickInfoSection: some View {
        HStack(spacing: 20) {
            if let prep = recipe.prepTimeMinutes {
                infoItem(title: "Prep", value: "\(prep) min", icon: "clock")
            }
            if let cook = recipe.cookTimeMinutes {
                infoItem(title: "Cook", value: "\(cook) min", icon: "flame")
            }
            infoItem(title: "Category", value: recipe.category.rawValue, icon: recipe.category.icon)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.accent)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var servingsAdjuster: some View {
        HStack {
            Text("Servings")
                .font(.headline)

            Spacer()

            HStack(spacing: 16) {
                Button {
                    if adjustedServings > 1 {
                        adjustedServings -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                }
                .disabled(adjustedServings <= 1)

                Text("\(adjustedServings)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 30)

                Button {
                    adjustedServings += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(recipe.ingredients) { ingredient in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .padding(.top, 6)
                            .foregroundStyle(.secondary)

                        Text(scaledIngredientText(ingredient))
                    }
                }
            }
        }
    }

    private func scaledIngredientText(_ ingredient: Ingredient) -> String {
        var parts: [String] = []

        if let qty = ingredient.quantity {
            let scaled = qty * servingMultiplier
            parts.append(formatQuantity(scaled))
        }

        if let unit = ingredient.unit, !unit.isEmpty {
            parts.append(unit)
        }

        parts.append(ingredient.name)

        if let notes = ingredient.notes, !notes.isEmpty {
            parts.append("(\(notes))")
        }

        return parts.joined(separator: " ")
    }

    private func formatQuantity(_ value: Double) -> String {
        let fractions: [(Double, String)] = [
            (0.125, "1/8"), (0.25, "1/4"), (0.333, "1/3"),
            (0.5, "1/2"), (0.666, "2/3"), (0.75, "3/4")
        ]

        let whole = Int(value)
        let fraction = value - Double(whole)

        if fraction < 0.05 {
            return "\(whole)"
        }

        for (threshold, display) in fractions {
            if abs(fraction - threshold) < 0.05 {
                return whole == 0 ? display : "\(whole) \(display)"
            }
        }

        return value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(recipe.instructions.sorted(by: { $0.stepNumber < $1.stepNumber })) { instruction in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(instruction.stepNumber)")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.accentColor)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(instruction.text)

                            if let timer = instruction.timerMinutes {
                                Label("\(timer) min", systemImage: "timer")
                                    .font(.caption)
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)

            Text(recipe.notes)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            title: "Spaghetti Carbonara",
            summary: "Classic Italian pasta dish with eggs, cheese, and pancetta",
            ingredients: [
                Ingredient(name: "Spaghetti", quantity: 1, unit: "lb"),
                Ingredient(name: "Eggs", quantity: 4),
                Ingredient(name: "Pecorino Romano", quantity: 1, unit: "cup", notes: "grated"),
                Ingredient(name: "Pancetta", quantity: 8, unit: "oz"),
                Ingredient(name: "Black pepper", quantity: 1, unit: "tsp")
            ],
            instructions: [
                Instruction(stepNumber: 1, text: "Bring a large pot of salted water to boil", timerMinutes: 10),
                Instruction(stepNumber: 2, text: "Cook spaghetti according to package directions"),
                Instruction(stepNumber: 3, text: "While pasta cooks, fry pancetta until crispy", timerMinutes: 8),
                Instruction(stepNumber: 4, text: "Whisk eggs and cheese together"),
                Instruction(stepNumber: 5, text: "Toss hot pasta with pancetta, then egg mixture")
            ],
            prepTimeMinutes: 10,
            cookTimeMinutes: 20,
            servings: 4,
            category: .dinner,
            notes: "Use the hot pasta water to adjust consistency if needed."
        ))
    }
    .modelContainer(for: Recipe.self, inMemory: true)
}

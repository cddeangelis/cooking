import SwiftUI
import SwiftData
import PhotosUI

struct RecipeEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existingRecipe: Recipe?

    @State private var title: String
    @State private var summary: String
    @State private var ingredients: [Ingredient]
    @State private var instructions: [Instruction]
    @State private var prepTimeMinutes: Int?
    @State private var cookTimeMinutes: Int?
    @State private var servings: Int
    @State private var category: Category
    @State private var notes: String
    @State private var imageData: Data?

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingImageOptions = false

    init(recipe: Recipe?) {
        self.existingRecipe = recipe
        self._title = State(initialValue: recipe?.title ?? "")
        self._summary = State(initialValue: recipe?.summary ?? "")
        self._ingredients = State(initialValue: recipe?.ingredients ?? [Ingredient()])
        self._instructions = State(initialValue: recipe?.instructions ?? [Instruction(stepNumber: 1)])
        self._prepTimeMinutes = State(initialValue: recipe?.prepTimeMinutes)
        self._cookTimeMinutes = State(initialValue: recipe?.cookTimeMinutes)
        self._servings = State(initialValue: recipe?.servings ?? 4)
        self._category = State(initialValue: recipe?.category ?? .dinner)
        self._notes = State(initialValue: recipe?.notes ?? "")
        self._imageData = State(initialValue: recipe?.imageData)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            basicInfoSection
            photoSection
            timingSection
            ingredientsSection
            instructionsSection
            notesSection
        }
        .navigationTitle(existingRecipe == nil ? "New Recipe" : "Edit Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveRecipe()
                }
                .disabled(!isValid)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Recipe Title", text: $title)

            TextField("Description (optional)", text: $summary, axis: .vertical)
                .lineLimit(2...4)

            Picker("Category", selection: $category) {
                ForEach(Category.allCases) { cat in
                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                }
            }

            Stepper("Servings: \(servings)", value: $servings, in: 1...50)
        }
    }

    private var photoSection: some View {
        Section("Photo") {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        showingImageOptions = true
                    }
                    .confirmationDialog("Photo Options", isPresented: $showingImageOptions) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Text("Choose New Photo")
                        }
                        Button("Remove Photo", role: .destructive) {
                            self.imageData = nil
                        }
                        Button("Cancel", role: .cancel) { }
                    }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Add Photo", systemImage: "photo.badge.plus")
                }
            }
        }
    }

    private var timingSection: some View {
        Section("Timing") {
            HStack {
                Text("Prep Time")
                Spacer()
                TextField("min", value: $prepTimeMinutes, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                Text("min")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Cook Time")
                Spacer()
                TextField("min", value: $cookTimeMinutes, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                Text("min")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var ingredientsSection: some View {
        Section {
            ForEach($ingredients) { $ingredient in
                IngredientEditRow(ingredient: $ingredient)
            }
            .onDelete(perform: deleteIngredient)
            .onMove(perform: moveIngredient)

            Button {
                ingredients.append(Ingredient())
            } label: {
                Label("Add Ingredient", systemImage: "plus.circle")
            }
        } header: {
            Text("Ingredients")
        }
    }

    private var instructionsSection: some View {
        Section {
            ForEach($instructions) { $instruction in
                InstructionEditRow(instruction: $instruction)
            }
            .onDelete(perform: deleteInstruction)
            .onMove(perform: moveInstruction)

            Button {
                let nextStep = (instructions.map(\.stepNumber).max() ?? 0) + 1
                instructions.append(Instruction(stepNumber: nextStep))
            } label: {
                Label("Add Step", systemImage: "plus.circle")
            }
        } header: {
            Text("Instructions")
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Additional notes...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
        if ingredients.isEmpty {
            ingredients.append(Ingredient())
        }
    }

    private func moveIngredient(from source: IndexSet, to destination: Int) {
        ingredients.move(fromOffsets: source, toOffset: destination)
    }

    private func deleteInstruction(at offsets: IndexSet) {
        instructions.remove(atOffsets: offsets)
        if instructions.isEmpty {
            instructions.append(Instruction(stepNumber: 1))
        }
        renumberInstructions()
    }

    private func moveInstruction(from source: IndexSet, to destination: Int) {
        instructions.move(fromOffsets: source, toOffset: destination)
        renumberInstructions()
    }

    private func renumberInstructions() {
        for (index, _) in instructions.enumerated() {
            instructions[index].stepNumber = index + 1
        }
    }

    private func saveRecipe() {
        let cleanedIngredients = ingredients.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let cleanedInstructions = instructions.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        if let recipe = existingRecipe {
            recipe.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            recipe.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
            recipe.ingredients = cleanedIngredients
            recipe.instructions = cleanedInstructions
            recipe.prepTimeMinutes = prepTimeMinutes
            recipe.cookTimeMinutes = cookTimeMinutes
            recipe.servings = servings
            recipe.category = category
            recipe.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            recipe.imageData = imageData
            recipe.updatedAt = Date()
        } else {
            let newRecipe = Recipe(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                summary: summary.trimmingCharacters(in: .whitespacesAndNewlines),
                ingredients: cleanedIngredients,
                instructions: cleanedInstructions,
                prepTimeMinutes: prepTimeMinutes,
                cookTimeMinutes: cookTimeMinutes,
                servings: servings,
                category: category,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                imageData: imageData
            )
            modelContext.insert(newRecipe)
        }

        dismiss()
    }
}

struct IngredientEditRow: View {
    @Binding var ingredient: Ingredient

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Qty", value: $ingredient.quantity, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 50)
                    .textFieldStyle(.roundedBorder)

                TextField("Unit", text: Binding(
                    get: { ingredient.unit ?? "" },
                    set: { ingredient.unit = $0.isEmpty ? nil : $0 }
                ))
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)

                TextField("Ingredient name", text: $ingredient.name)
                    .textFieldStyle(.roundedBorder)
            }

            TextField("Notes (optional)", text: Binding(
                get: { ingredient.notes ?? "" },
                set: { ingredient.notes = $0.isEmpty ? nil : $0 }
            ))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct InstructionEditRow: View {
    @Binding var instruction: Instruction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("\(instruction.stepNumber).")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 30, alignment: .leading)

                TextField("Describe this step...", text: $instruction.text, axis: .vertical)
                    .lineLimit(2...5)
            }

            HStack {
                Image(systemName: "timer")
                    .foregroundStyle(.secondary)
                    .font(.caption)

                TextField("Timer (min)", value: $instruction.timerMinutes, format: .number)
                    .keyboardType(.numberPad)
                    .font(.caption)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)

                Text("optional")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        RecipeEditView(recipe: nil)
    }
    .modelContainer(for: Recipe.self, inMemory: true)
}

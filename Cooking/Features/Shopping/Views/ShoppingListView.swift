import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShoppingItem.createdAt) private var items: [ShoppingItem]
    @Query private var recipes: [Recipe]

    @State private var showingAddItem = false
    @State private var showingAddFromRecipe = false
    @State private var newItemName = ""

    private var groupedItems: [(ShoppingSection, [ShoppingItem])] {
        let unchecked = items.filter { !$0.isChecked }
        let grouped = Dictionary(grouping: unchecked) { $0.section }
        return ShoppingSection.allCases.compactMap { section in
            guard let sectionItems = grouped[section], !sectionItems.isEmpty else { return nil }
            return (section, sectionItems)
        }
    }

    private var checkedItems: [ShoppingItem] {
        items.filter { $0.isChecked }
    }

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    shoppingList
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showingAddFromRecipe = true
                        } label: {
                            Label("Add from Recipe", systemImage: "book.closed")
                        }

                        if !checkedItems.isEmpty {
                            Divider()
                            Button(role: .destructive) {
                                clearCheckedItems()
                            } label: {
                                Label("Clear Checked Items", systemImage: "trash")
                            }
                        }

                        if !items.isEmpty {
                            Button(role: .destructive) {
                                clearAllItems()
                            } label: {
                                Label("Clear All", systemImage: "trash.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddShoppingItemSheet()
            }
            .sheet(isPresented: $showingAddFromRecipe) {
                AddFromRecipeSheet(recipes: recipes)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Shopping List Empty", systemImage: "cart")
        } description: {
            Text("Add items manually or from your recipes")
        } actions: {
            HStack {
                Button("Add Item") {
                    showingAddItem = true
                }
                .buttonStyle(.borderedProminent)

                Button("From Recipe") {
                    showingAddFromRecipe = true
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var shoppingList: some View {
        List {
            ForEach(groupedItems, id: \.0) { section, sectionItems in
                Section {
                    ForEach(sectionItems) { item in
                        ShoppingItemRow(item: item)
                    }
                    .onDelete { indexSet in
                        deleteItems(sectionItems, at: indexSet)
                    }
                } header: {
                    Label(section.rawValue, systemImage: section.icon)
                }
            }

            if !checkedItems.isEmpty {
                Section("Checked Off") {
                    ForEach(checkedItems) { item in
                        ShoppingItemRow(item: item)
                    }
                    .onDelete { indexSet in
                        deleteItems(checkedItems, at: indexSet)
                    }
                }
            }
        }
    }

    private func deleteItems(_ list: [ShoppingItem], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(list[index])
        }
    }

    private func clearCheckedItems() {
        for item in checkedItems {
            modelContext.delete(item)
        }
    }

    private func clearAllItems() {
        for item in items {
            modelContext.delete(item)
        }
    }
}

struct ShoppingItemRow: View {
    @Bindable var item: ShoppingItem

    var body: some View {
        HStack {
            Button {
                withAnimation {
                    item.isChecked.toggle()
                }
            } label: {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isChecked ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.displayText)
                .strikethrough(item.isChecked)
                .foregroundStyle(item.isChecked ? .secondary : .primary)

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                item.isChecked.toggle()
            }
        }
    }
}

struct AddShoppingItemSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var quantity: Double?
    @State private var unit = ""
    @State private var section: ShoppingSection = .other

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item name", text: $name)

                    HStack {
                        TextField("Qty", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)

                        TextField("Unit (optional)", text: $unit)
                    }

                    Picker("Section", selection: $section) {
                        ForEach(ShoppingSection.allCases) { sec in
                            Label(sec.rawValue, systemImage: sec.icon).tag(sec)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: name) { _, newValue in
                if section == .other {
                    section = ShoppingSection.guess(for: newValue)
                }
            }
        }
    }

    private func addItem() {
        let item = ShoppingItem(
            name: name.trimmingCharacters(in: .whitespaces),
            quantity: quantity,
            unit: unit.isEmpty ? nil : unit,
            section: section
        )
        modelContext.insert(item)
        dismiss()
    }
}

struct AddFromRecipeSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let recipes: [Recipe]
    @State private var selectedRecipes: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List(recipes, selection: $selectedRecipes) { recipe in
                HStack {
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        Text("\(recipe.ingredients.count) ingredients")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if selectedRecipes.contains(recipe.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.accent)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedRecipes.contains(recipe.id) {
                        selectedRecipes.remove(recipe.id)
                    } else {
                        selectedRecipes.insert(recipe.id)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Add from Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addIngredients()
                    }
                    .disabled(selectedRecipes.isEmpty)
                }
            }
        }
    }

    private func addIngredients() {
        for recipe in recipes where selectedRecipes.contains(recipe.id) {
            for ingredient in recipe.ingredients {
                let item = ShoppingItem.from(ingredient: ingredient, recipeId: recipe.id)
                modelContext.insert(item)
            }
        }
        dismiss()
    }
}

#Preview {
    ShoppingListView()
        .modelContainer(for: [ShoppingItem.self, Recipe.self], inMemory: true)
}

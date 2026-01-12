import SwiftUI
import SwiftData

struct MealPlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var mealPlans: [MealPlan]
    @Query private var recipes: [Recipe]

    @State private var selectedDate = Date()
    @State private var showingAddMeal = false
    @State private var selectedMealType: MealType = .dinner

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func mealsForDate(_ date: Date) -> [MealPlan] {
        let calendar = Calendar.current
        return mealPlans.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.mealType.sortOrder < $1.mealType.sortOrder }
    }

    private func recipe(for mealPlan: MealPlan) -> Recipe? {
        guard let recipeId = mealPlan.recipeId else { return nil }
        return recipes.first { $0.id == recipeId }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                weekSelector
                weekView
            }
            .navigationTitle("Meal Plan")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        selectedDate = Date()
                    } label: {
                        Text("Today")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealPlanSheet(
                    date: selectedDate,
                    mealType: selectedMealType,
                    recipes: recipes
                )
            }
        }
    }

    private var weekSelector: some View {
        HStack {
            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(weekRangeText)
                .font(.headline)

            Spacer()

            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }

    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        guard let first = weekDates.first, let last = weekDates.last else { return "" }
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }

    private var weekView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(weekDates, id: \.self) { date in
                    dayCard(for: date)
                }
            }
            .padding()
        }
    }

    private func dayCard(for date: Date) -> some View {
        let meals = mealsForDate(date)
        let isToday = Calendar.current.isDateInToday(date)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dayLabel(for: date))
                    .font(.headline)
                    .foregroundStyle(isToday ? .accent : .primary)

                if isToday {
                    Text("Today")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Spacer()

                Menu {
                    ForEach(MealType.allCases) { mealType in
                        Button {
                            selectedDate = date
                            selectedMealType = mealType
                            showingAddMeal = true
                        } label: {
                            Label("Add \(mealType.rawValue)", systemImage: mealType.icon)
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                }
            }

            if meals.isEmpty {
                Text("No meals planned")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(meals) { meal in
                    mealRow(meal)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    private func mealRow(_ meal: MealPlan) -> some View {
        HStack(spacing: 12) {
            Image(systemName: meal.mealType.icon)
                .foregroundStyle(.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(meal.mealType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let recipe = recipe(for: meal) {
                    Text(recipe.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else if !meal.notes.isEmpty {
                    Text(meal.notes)
                        .font(.subheadline)
                } else {
                    Text("No recipe selected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(role: .destructive) {
                modelContext.delete(meal)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

struct AddMealPlanSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let date: Date
    let mealType: MealType
    let recipes: [Recipe]

    @State private var selectedMealType: MealType
    @State private var selectedRecipeId: UUID?
    @State private var notes = ""

    init(date: Date, mealType: MealType, recipes: [Recipe]) {
        self.date = date
        self.mealType = mealType
        self.recipes = recipes
        self._selectedMealType = State(initialValue: mealType)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(formattedDate)
                            .foregroundStyle(.secondary)
                    }

                    Picker("Meal", selection: $selectedMealType) {
                        ForEach(MealType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                }

                Section("Recipe") {
                    if recipes.isEmpty {
                        Text("No recipes available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(recipes) { recipe in
                            Button {
                                selectedRecipeId = recipe.id
                            } label: {
                                HStack {
                                    Text(recipe.title)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedRecipeId == recipe.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.accent)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Or add a note") {
                    TextField("e.g., Leftovers, Eating out...", text: $notes)
                }
            }
            .navigationTitle("Plan Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMealPlan()
                    }
                    .disabled(selectedRecipeId == nil && notes.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func addMealPlan() {
        let mealPlan = MealPlan(
            date: date,
            mealType: selectedMealType,
            recipeId: selectedRecipeId,
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(mealPlan)
        dismiss()
    }
}

#Preview {
    MealPlannerView()
        .modelContainer(for: [MealPlan.self, Recipe.self], inMemory: true)
}

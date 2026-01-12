import Foundation
import SwiftData

@Model
final class MealPlan {
    var id: UUID
    var date: Date
    var mealType: MealType
    var recipeId: UUID?
    var notes: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mealType: MealType = .dinner,
        recipeId: UUID? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipeId = recipeId
        self.notes = notes
    }

    var dateOnly: Date {
        Calendar.current.startOfDay(for: date)
    }
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakfast: return "sun.horizon"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        }
    }

    var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch: return 1
        case .dinner: return 2
        }
    }
}

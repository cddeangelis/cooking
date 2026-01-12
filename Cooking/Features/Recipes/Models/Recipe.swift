import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var title: String
    var summary: String
    var ingredients: [Ingredient]
    var instructions: [Instruction]
    var prepTimeMinutes: Int?
    var cookTimeMinutes: Int?
    var servings: Int
    var category: Category
    var tags: [String]
    var isFavorite: Bool
    @Attribute(.externalStorage) var imageData: Data?
    var sourceURL: String?
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        summary: String = "",
        ingredients: [Ingredient] = [],
        instructions: [Instruction] = [],
        prepTimeMinutes: Int? = nil,
        cookTimeMinutes: Int? = nil,
        servings: Int = 4,
        category: Category = .dinner,
        tags: [String] = [],
        isFavorite: Bool = false,
        imageData: Data? = nil,
        sourceURL: String? = nil,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.servings = servings
        self.category = category
        self.tags = tags
        self.isFavorite = isFavorite
        self.imageData = imageData
        self.sourceURL = sourceURL
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var totalTimeMinutes: Int? {
        switch (prepTimeMinutes, cookTimeMinutes) {
        case let (prep?, cook?):
            return prep + cook
        case let (prep?, nil):
            return prep
        case let (nil, cook?):
            return cook
        case (nil, nil):
            return nil
        }
    }

    var formattedTotalTime: String? {
        guard let total = totalTimeMinutes else { return nil }
        if total < 60 {
            return "\(total) min"
        } else {
            let hours = total / 60
            let minutes = total % 60
            if minutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(minutes) min"
            }
        }
    }
}

struct Ingredient: Codable, Hashable, Identifiable {
    var id: UUID
    var name: String
    var quantity: Double?
    var unit: String?
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String = "",
        quantity: Double? = nil,
        unit: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.notes = notes
    }

    var displayText: String {
        var parts: [String] = []

        if let qty = quantity {
            parts.append(formatQuantity(qty))
        }

        if let u = unit, !u.isEmpty {
            parts.append(u)
        }

        parts.append(name)

        if let n = notes, !n.isEmpty {
            parts.append("(\(n))")
        }

        return parts.joined(separator: " ")
    }

    private func formatQuantity(_ value: Double) -> String {
        let fractions: [(Double, String)] = [
            (0.125, "1/8"),
            (0.25, "1/4"),
            (0.333, "1/3"),
            (0.5, "1/2"),
            (0.666, "2/3"),
            (0.75, "3/4")
        ]

        let whole = Int(value)
        let fraction = value - Double(whole)

        if fraction < 0.05 {
            return "\(whole)"
        }

        for (threshold, display) in fractions {
            if abs(fraction - threshold) < 0.05 {
                if whole == 0 {
                    return display
                } else {
                    return "\(whole) \(display)"
                }
            }
        }

        if value == value.rounded() {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

struct Instruction: Codable, Hashable, Identifiable {
    var id: UUID
    var stepNumber: Int
    var text: String
    var timerMinutes: Int?

    init(
        id: UUID = UUID(),
        stepNumber: Int = 1,
        text: String = "",
        timerMinutes: Int? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.text = text
        self.timerMinutes = timerMinutes
    }
}

enum Category: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case dessert = "Dessert"
    case snack = "Snack"
    case drink = "Drink"
    case appetizer = "Appetizer"
    case side = "Side Dish"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breakfast: return "sun.horizon"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .dessert: return "birthday.cake"
        case .snack: return "carrot"
        case .drink: return "cup.and.saucer"
        case .appetizer: return "fork.knife"
        case .side: return "leaf"
        }
    }
}

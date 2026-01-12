import Foundation
import SwiftData

@Model
final class ShoppingItem {
    var id: UUID
    var name: String
    var quantity: Double?
    var unit: String?
    var section: ShoppingSection
    var isChecked: Bool
    var recipeId: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        quantity: Double? = nil,
        unit: String? = nil,
        section: ShoppingSection = .other,
        isChecked: Bool = false,
        recipeId: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.section = section
        self.isChecked = isChecked
        self.recipeId = recipeId
        self.createdAt = createdAt
    }

    var displayText: String {
        var parts: [String] = []

        if let qty = quantity {
            if qty == qty.rounded() {
                parts.append("\(Int(qty))")
            } else {
                parts.append(String(format: "%.1f", qty))
            }
        }

        if let u = unit, !u.isEmpty {
            parts.append(u)
        }

        parts.append(name)

        return parts.joined(separator: " ")
    }

    static func from(ingredient: Ingredient, recipeId: UUID) -> ShoppingItem {
        ShoppingItem(
            name: ingredient.name,
            quantity: ingredient.quantity,
            unit: ingredient.unit,
            section: ShoppingSection.guess(for: ingredient.name),
            recipeId: recipeId
        )
    }
}

enum ShoppingSection: String, Codable, CaseIterable, Identifiable {
    case produce = "Produce"
    case dairy = "Dairy"
    case meat = "Meat & Seafood"
    case bakery = "Bakery"
    case frozen = "Frozen"
    case pantry = "Pantry"
    case spices = "Spices & Seasonings"
    case beverages = "Beverages"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .produce: return "leaf"
        case .dairy: return "cup.and.saucer"
        case .meat: return "fish"
        case .bakery: return "birthday.cake"
        case .frozen: return "snowflake"
        case .pantry: return "cabinet"
        case .spices: return "leaf.circle"
        case .beverages: return "waterbottle"
        case .other: return "bag"
        }
    }

    static func guess(for ingredientName: String) -> ShoppingSection {
        let name = ingredientName.lowercased()

        let produceKeywords = ["lettuce", "tomato", "onion", "garlic", "pepper", "carrot", "celery", "potato", "apple", "banana", "orange", "lemon", "lime", "avocado", "cucumber", "spinach", "kale", "broccoli", "mushroom", "ginger", "cilantro", "parsley", "basil", "mint"]
        let dairyKeywords = ["milk", "cheese", "butter", "cream", "yogurt", "egg", "sour cream"]
        let meatKeywords = ["chicken", "beef", "pork", "fish", "salmon", "shrimp", "bacon", "sausage", "turkey", "lamb"]
        let bakeryKeywords = ["bread", "roll", "baguette", "tortilla", "pita", "croissant"]
        let frozenKeywords = ["frozen", "ice cream"]
        let spiceKeywords = ["salt", "pepper", "cumin", "paprika", "oregano", "thyme", "cinnamon", "nutmeg", "cayenne", "chili powder", "curry"]
        let beverageKeywords = ["juice", "wine", "beer", "soda", "water", "coffee", "tea"]

        if produceKeywords.contains(where: { name.contains($0) }) { return .produce }
        if dairyKeywords.contains(where: { name.contains($0) }) { return .dairy }
        if meatKeywords.contains(where: { name.contains($0) }) { return .meat }
        if bakeryKeywords.contains(where: { name.contains($0) }) { return .bakery }
        if frozenKeywords.contains(where: { name.contains($0) }) { return .frozen }
        if spiceKeywords.contains(where: { name.contains($0) }) { return .spices }
        if beverageKeywords.contains(where: { name.contains($0) }) { return .beverages }

        return .pantry
    }
}

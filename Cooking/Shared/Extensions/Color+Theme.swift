import SwiftUI

extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    let primary = Color("AccentColor")
    let background = Color(uiColor: .systemBackground)
    let secondaryBackground = Color(uiColor: .secondarySystemBackground)

    // Warm cooking-inspired colors
    let warmOrange = Color(red: 1.0, green: 0.42, blue: 0.21)    // #FF6B35
    let sageGreen = Color(red: 0.55, green: 0.70, blue: 0.41)    // #8CB369
    let cream = Color(red: 1.0, green: 0.97, blue: 0.94)         // #FFF8F0
    let darkBrown = Color(red: 0.24, green: 0.16, blue: 0.08)    // #3D2914
}

extension ShapeStyle where Self == Color {
    static var accent: Color { .accentColor }
}

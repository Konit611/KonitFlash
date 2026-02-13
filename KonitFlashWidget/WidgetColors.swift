import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    static let widgetBackground = Color(hex: 0x040422)
    static let widgetStreakPink = Color(hex: 0xFFC7EA)
    static let widgetLearnedGreen = Color(hex: 0xD4F849)

    static func widgetColorTag(_ tag: String) -> Color {
        switch tag {
        case "pink": return Color(hex: 0xFFC7EA)
        case "green": return Color(hex: 0xD4F849)
        default: return Color(hex: 0xFFC7EA)
        }
    }
}

import SwiftUI

extension Color {
    static let appBackground = Color(hex: 0x040422)
    static let overdueBg = Color(hex: 0xFFDADA)
    static let overdueText = Color(hex: 0xEF3E3E)
    static let streakPink = Color(hex: 0xFFC7EA)
    static let learnedGreen = Color(hex: 0xD4F849)
    static let reviewsGreen = Color(hex: 0xE5FB92)
    static let weeklyMint = Color(hex: 0x9CF2E8)
    static let weeklyMintLight = Color(hex: 0xBAF6EF)
    static let weeklyCompleted = Color(hex: 0x3B3B3B)
    static let deckBadge = Color(hex: 0xFFDDF2)

    static func colorForTag(_ tag: ColorTag) -> Color {
        switch tag {
        case .pink: return .streakPink
        case .green: return .learnedGreen
        }
    }

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

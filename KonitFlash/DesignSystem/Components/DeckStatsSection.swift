import SwiftUI

struct DeckStatsSection: View {
    let newCount: String
    let learningCount: String
    let reviewedCount: String
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        HStack(spacing: isRegular ? 8 : 6) {
            statCard(value: newCount, label: String(localized: "NEW", bundle: LanguageManager.shared.bundle), color: .streakPink)
            statCard(value: learningCount, label: String(localized: "LEARNING", bundle: LanguageManager.shared.bundle), color: .learnedGreen)
            statCard(value: reviewedCount, label: String(localized: "REVIEWED", bundle: LanguageManager.shared.bundle), color: .weeklyMint)
        }
    }

    private func statCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: isRegular ? 12 : 4) {
            Text(value)
                .font(.system(size: isRegular ? 64 : 36, weight: .bold))
                .foregroundStyle(.black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text(label)
                .font(.system(size: isRegular ? 20 : 14, weight: .bold))
                .foregroundStyle(Color(hex: 0x7C6172))
                .tracking(1)
        }
        .frame(maxWidth: .infinity, maxHeight: isRegular ? .infinity : nil)
        .frame(height: isRegular ? nil : 100)
        .background(color, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }
}

#Preview("iPhone") {
    DeckStatsSection(
        newCount: "6",
        learningCount: "12",
        reviewedCount: "121"
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    DeckStatsSection(
        newCount: "6",
        learningCount: "12",
        reviewedCount: "121"
    )
    .frame(width: 620, height: 241)
    .padding(64)
    .background(Color.appBackground)
}

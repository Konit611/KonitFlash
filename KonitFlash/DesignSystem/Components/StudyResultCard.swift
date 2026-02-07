import SwiftUI

struct StudyResultCard: View {
    let accuracyPercent: Double
    let totalCards: Int
    let elapsedTime: String
    let goodEasyCount: Int
    let againHardCount: Int
    let message: String
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(spacing: isRegular ? 24 : 16) {
            Text("Session Complete!")
                .font(.system(size: isRegular ? 28 : 24, weight: .bold))
                .foregroundStyle(.black)

            accuracyRing

            statsGrid

            Text(message)
                .font(.system(size: isRegular ? 18 : 15, weight: .medium))
                .foregroundStyle(Color(hex: 0x555555))
                .multilineTextAlignment(.center)
        }
        .padding(isRegular ? 32 : 24)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    private var accuracyRing: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: 0xE8E8E8), lineWidth: isRegular ? 12 : 8)
            Circle()
                .trim(from: 0, to: accuracyPercent / 100)
                .stroke(Color.learnedGreen, style: StrokeStyle(lineWidth: isRegular ? 12 : 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(accuracyPercent))%")
                .font(.system(size: isRegular ? 32 : 24, weight: .bold))
                .foregroundStyle(.black)
        }
        .frame(width: isRegular ? 140 : 120, height: isRegular ? 140 : 120)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: isRegular ? 16 : 12) {
            statItem(title: "Total", value: "\(totalCards)", icon: "square.stack.fill")
            statItem(title: "Time", value: elapsedTime, icon: "clock.fill")
            statItem(title: "Good + Easy", value: "\(goodEasyCount)", icon: "checkmark.circle.fill")
            statItem(title: "Again + Hard", value: "\(againHardCount)", icon: "arrow.counterclockwise")
        }
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: isRegular ? 16 : 14))
                .foregroundStyle(Color(hex: 0x9095A1))
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                    .foregroundStyle(.black)
                Text(title)
                    .font(.system(size: isRegular ? 14 : 12))
                    .foregroundStyle(Color(hex: 0x9095A1))
            }
            Spacer()
        }
        .padding(isRegular ? 14 : 10)
        .background(Color(hex: 0xF5F5F5), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview("iPhone") {
    StudyResultCard(
        accuracyPercent: 80,
        totalCards: 5,
        elapsedTime: "2:30",
        goodEasyCount: 4,
        againHardCount: 1,
        message: "Excellent work! Keep it up!"
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    StudyResultCard(
        accuracyPercent: 80,
        totalCards: 5,
        elapsedTime: "2:30",
        goodEasyCount: 4,
        againHardCount: 1,
        message: "Excellent work! Keep it up!"
    )
    .padding(40)
    .frame(width: 700)
    .background(Color.appBackground)
}

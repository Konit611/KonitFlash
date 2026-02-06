import SwiftUI

struct WeeklyChartView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let totals = [43, 18, 21, 21, 11, 52, 24]
    private let completed = [43, 6, 0, 0, 0, 0, 0]
    private let todayIndex = 2 // Wednesday

    private var isRegular: Bool { sizeClass == .regular }
    private var maxTotal: Int { totals.max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: isRegular ? 16 : 12) {
            Text("Weekly Completion")
                .font(.system(size: isRegular ? 18 : 14, weight: .bold))
                .foregroundStyle(.black)

            GeometryReader { geo in
                let spacing: CGFloat = isRegular ? 12 : 0
                let availableWidth = geo.size.width - (spacing * CGFloat(days.count - 1))
                let barWidth = isRegular ? (availableWidth / CGFloat(days.count)) : geo.size.width / CGFloat(days.count)
                let chartHeight = geo.size.height - (isRegular ? 30 : 24)

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                        VStack(spacing: isRegular ? 8 : 4) {
                            // Count label
                            Text("\(completed[index])/\(totals[index])")
                                .font(.system(size: isRegular ? 12 : 8))
                                .foregroundStyle(Color(hex: 0x777F8F))

                            // Bar
                            ZStack(alignment: .bottom) {
                                // Background bar
                                UnevenRoundedRectangle(
                                    topLeadingRadius: isRegular ? 30 : 5,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: isRegular ? 30 : 5
                                )
                                .fill(Color.weeklyMintLight)
                                .frame(
                                    width: isRegular ? barWidth : 7,
                                    height: barHeight(for: totals[index], maxHeight: chartHeight - 20)
                                )

                                // Filled bar
                                if completed[index] > 0 {
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: isRegular ? 30 : 5,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: isRegular ? 30 : 5
                                    )
                                    .fill(Color.weeklyCompleted)
                                    .frame(
                                        width: isRegular ? barWidth : 7,
                                        height: barHeight(for: completed[index], maxHeight: chartHeight - 20)
                                    )
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)

                            // Day label
                            Text(day)
                                .font(.system(size: isRegular ? 16 : 12, weight: index == todayIndex ? .semibold : .regular))
                                .foregroundStyle(index == todayIndex ? Color(hex: 0x060606) : Color(hex: 0x7C6172))
                        }
                        .frame(maxWidth: isRegular ? nil : .infinity)
                    }
                }
            }
            .frame(height: isRegular ? 180 : 120)
        }
        .padding(isRegular ? 20 : 15)
        .background(Color.weeklyMint, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }

    private func barHeight(for value: Int, maxHeight: CGFloat) -> CGFloat {
        let ratio = CGFloat(value) / CGFloat(maxTotal)
        return max(4, ratio * maxHeight)
    }
}

#Preview("iPhone") {
    WeeklyChartView()
        .padding()
        .background(Color.appBackground)
}

#Preview("Mac") {
    WeeklyChartView()
        .padding(64)
        .frame(width: 1440)
        .background(Color.appBackground)
}

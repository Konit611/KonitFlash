import SwiftUI

struct WeeklyChartView: View {
    let data: [DayBarData]
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }
    private var maxTotal: Int { data.map(\.totalCards).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: isRegular ? 16 : 12) {
            Text("Weekly Completion")
                .font(.system(size: isRegular ? 18 : 14, weight: .bold))
                .foregroundStyle(.black)

            GeometryReader { geo in
                let spacing: CGFloat = isRegular ? 12 : 0
                let availableWidth = geo.size.width - (spacing * CGFloat(data.count - 1))
                let barWidth = isRegular ? (availableWidth / CGFloat(data.count)) : geo.size.width / CGFloat(data.count)
                let chartHeight = geo.size.height - (isRegular ? 30 : 24)

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(data) { bar in
                        VStack(spacing: isRegular ? 8 : 4) {
                            Text(bar.completionLabel)
                                .font(.system(size: isRegular ? 12 : 8))
                                .foregroundStyle(Color(hex: 0x777F8F))

                            ZStack(alignment: .bottom) {
                                UnevenRoundedRectangle(
                                    topLeadingRadius: isRegular ? 30 : 5,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 0,
                                    topTrailingRadius: isRegular ? 30 : 5
                                )
                                .fill(Color.weeklyMintLight)
                                .frame(
                                    width: isRegular ? barWidth : 7,
                                    height: barHeight(for: bar.totalCards, maxHeight: chartHeight - 20)
                                )

                                if bar.completedCards > 0 {
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: isRegular ? 30 : 5,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: isRegular ? 30 : 5
                                    )
                                    .fill(Color.weeklyCompleted)
                                    .frame(
                                        width: isRegular ? barWidth : 7,
                                        height: barHeight(for: bar.completedCards, maxHeight: chartHeight - 20)
                                    )
                                }
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)

                            Text(bar.dayLabel)
                                .font(.system(size: isRegular ? 16 : 12, weight: bar.isToday ? .semibold : .regular))
                                .foregroundStyle(bar.isToday ? Color(hex: 0x060606) : Color(hex: 0x7C6172))
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
    WeeklyChartView(data: [
        DayBarData(dayLabel: "Mon", totalCards: 43, completedCards: 43, isToday: false),
        DayBarData(dayLabel: "Tue", totalCards: 18, completedCards: 6, isToday: false),
        DayBarData(dayLabel: "Wed", totalCards: 21, completedCards: 0, isToday: true),
        DayBarData(dayLabel: "Thu", totalCards: 21, completedCards: 0, isToday: false),
        DayBarData(dayLabel: "Fri", totalCards: 11, completedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sat", totalCards: 52, completedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sun", totalCards: 24, completedCards: 0, isToday: false),
    ])
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    WeeklyChartView(data: [
        DayBarData(dayLabel: "Mon", totalCards: 43, completedCards: 43, isToday: false),
        DayBarData(dayLabel: "Tue", totalCards: 18, completedCards: 6, isToday: false),
        DayBarData(dayLabel: "Wed", totalCards: 21, completedCards: 0, isToday: true),
        DayBarData(dayLabel: "Thu", totalCards: 21, completedCards: 0, isToday: false),
        DayBarData(dayLabel: "Fri", totalCards: 11, completedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sat", totalCards: 52, completedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sun", totalCards: 24, completedCards: 0, isToday: false),
    ])
    .padding(64)
    .frame(width: 1440)
    .background(Color.appBackground)
}

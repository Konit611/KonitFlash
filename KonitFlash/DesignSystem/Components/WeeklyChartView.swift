import SwiftUI

struct WeeklyChartView: View {
    let data: [DayBarData]
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }
    private var maxStudied: Int { max(data.map(\.studiedCards).max() ?? 1, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: isRegular ? 16 : 12) {
            Text("Weekly Activity", bundle: LanguageManager.shared.bundle)
                .font(.system(size: isRegular ? 24 : 14, weight: .bold))
                .foregroundStyle(.black)

            GeometryReader { geo in
                let spacing: CGFloat = isRegular ? 12 : 0
                let availableWidth = max(0, geo.size.width - (spacing * CGFloat(max(0, data.count - 1))))
                let barWidth = data.isEmpty ? 0 : max(0, isRegular ? (availableWidth / CGFloat(data.count)) : geo.size.width / CGFloat(data.count))
                let chartHeight = max(0, geo.size.height - (isRegular ? 36 : 24))

                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(data) { bar in
                        VStack(spacing: isRegular ? 8 : 4) {
                            if bar.studiedCards > 0 {
                                Text("\(bar.studiedCards)")
                                    .font(.system(size: isRegular ? 16 : 8))
                                    .foregroundStyle(Color(hex: 0x777F8F))
                            } else {
                                Text("")
                                    .font(.system(size: isRegular ? 16 : 8))
                            }

                            UnevenRoundedRectangle(
                                topLeadingRadius: isRegular ? 30 : 5,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: isRegular ? 30 : 5
                            )
                            .fill(bar.studiedCards > 0 ? Color.weeklyCompleted : Color.weeklyMintLight)
                            .frame(
                                width: max(0, isRegular ? barWidth : 7),
                                height: max(0, barHeight(for: max(bar.studiedCards, 1), maxHeight: max(0, chartHeight - 20)))
                            )
                            .frame(maxHeight: .infinity, alignment: .bottom)

                            Text(bar.dayLabel)
                                .font(.system(size: isRegular ? 20 : 12, weight: bar.isToday ? .semibold : .regular))
                                .foregroundStyle(bar.isToday ? Color(hex: 0x060606) : Color(hex: 0x7C6172))
                        }
                        .frame(maxWidth: isRegular ? nil : .infinity)
                    }
                }
            }
            .frame(height: isRegular ? 220 : 120)
        }
        .padding(isRegular ? 28 : 15)
        .background(Color.weeklyMint, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }

    private func barHeight(for value: Int, maxHeight: CGFloat) -> CGFloat {
        let ratio = CGFloat(value) / CGFloat(maxStudied)
        return max(4, ratio * maxHeight)
    }
}

#Preview("iPhone") {
    WeeklyChartView(data: [
        DayBarData(dayLabel: "Mon", studiedCards: 43, isToday: false),
        DayBarData(dayLabel: "Tue", studiedCards: 6, isToday: false),
        DayBarData(dayLabel: "Wed", studiedCards: 0, isToday: true),
        DayBarData(dayLabel: "Thu", studiedCards: 0, isToday: false),
        DayBarData(dayLabel: "Fri", studiedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sat", studiedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sun", studiedCards: 0, isToday: false),
    ])
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    WeeklyChartView(data: [
        DayBarData(dayLabel: "Mon", studiedCards: 43, isToday: false),
        DayBarData(dayLabel: "Tue", studiedCards: 6, isToday: false),
        DayBarData(dayLabel: "Wed", studiedCards: 0, isToday: true),
        DayBarData(dayLabel: "Thu", studiedCards: 0, isToday: false),
        DayBarData(dayLabel: "Fri", studiedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sat", studiedCards: 0, isToday: false),
        DayBarData(dayLabel: "Sun", studiedCards: 0, isToday: false),
    ])
    .padding(64)
    .frame(width: 1440)
    .background(Color.appBackground)
}

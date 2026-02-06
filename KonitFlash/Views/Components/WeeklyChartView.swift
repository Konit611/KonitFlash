import SwiftUI

struct WeeklyChartView: View {
    private let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let totals = [43, 43, 43, 43, 43, 43, 43]
    private let completed = [43, 10, 28, 0, 0, 0, 0]
    private let todayIndex = 2 // Wednesday

    private var maxTotal: Int { totals.max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Completion")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 4) {
                        // Count label
                        Text("\(completed[index])/\(totals[index])")
                            .font(.system(size: 8))
                            .foregroundStyle(Color(hex: 0x777F8F))

                        // Bar
                        ZStack(alignment: .bottom) {
                            // Background bar (total)
                            UnevenRoundedRectangle(
                                topLeadingRadius: 5, bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0, topTrailingRadius: 5
                            )
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 7, height: barHeight(for: totals[index]))

                            // Filled bar (completed)
                            if completed[index] > 0 {
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 5, bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 0, topTrailingRadius: 5
                                )
                                .fill(Color.weeklyCompleted)
                                .frame(width: 7, height: barHeight(for: completed[index]))
                            }
                        }
                        .frame(height: 98, alignment: .bottom)

                        // Day label
                        Text(day)
                            .font(.system(size: 12, weight: index == todayIndex ? .semibold : .regular))
                            .foregroundStyle(index == todayIndex ? Color(hex: 0x060606) : Color(hex: 0x7C6172))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(15)
        .background(Color.weeklyMint, in: RoundedRectangle(cornerRadius: 18))
    }

    private func barHeight(for value: Int) -> CGFloat {
        let ratio = CGFloat(value) / CGFloat(maxTotal)
        return max(4, ratio * 78)
    }
}

#Preview {
    WeeklyChartView()
        .padding()
        .background(Color.appBackground)
}

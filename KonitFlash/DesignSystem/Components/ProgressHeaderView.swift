import SwiftUI

struct ProgressHeaderView: View {
    let currentIndex: Int
    let totalCount: Int
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }
    private var progressFraction: Double {
        guard totalCount > 0 else { return 0 }
        return Double(currentIndex) / Double(totalCount)
    }

    var body: some View {
        VStack(spacing: isRegular ? 10 : 6) {
            Text("\(currentIndex) / \(totalCount)")
                .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                .foregroundStyle(.white)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: isRegular ? 10 : 6)
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.learnedGreen)
                        .frame(width: geo.size.width * progressFraction, height: isRegular ? 10 : 6)
                }
            }
            .frame(height: isRegular ? 10 : 6)
        }
    }
}

#Preview("iPhone") {
    ProgressHeaderView(currentIndex: 3, totalCount: 5)
        .padding()
        .background(Color.appBackground)
}

#Preview("Mac") {
    ProgressHeaderView(currentIndex: 3, totalCount: 5)
        .padding(40)
        .frame(width: 700)
        .background(Color.appBackground)
}

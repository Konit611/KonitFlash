import SwiftUI

struct OverdueBanner: View {
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.overdueText)
            Text("You have \(count) overdue cards !")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.overdueText)
            Spacer()
            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.overdueText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.overdueBg, in: RoundedRectangle(cornerRadius: 18))
    }
}

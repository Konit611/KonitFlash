import SwiftUI

struct OverdueBanner: View {
    let count: Int
    var isRegular: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: isRegular ? 24 : 18))
                .foregroundStyle(Color.overdueText)

            VStack(alignment: .leading, spacing: isRegular ? 2 : 0) {
                Text("You have \(count) overdue cards !")
                    .font(.system(size: isRegular ? 24 : 18, weight: .bold))
                    .foregroundStyle(Color.overdueText)
                if isRegular {
                    Text("It looks like you missed a few days. Don't worry, consistency is the key ! Let's clear some of that backlog now.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.overdueText)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isRegular {
                Button {
                } label: {
                    HStack(spacing: 6) {
                        Text("Catch Up Now")
                            .font(.system(size: 15))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Color.overdueText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.overdueText)
            }
        }
        .padding(.horizontal, isRegular ? 24 : 16)
        .padding(.vertical, isRegular ? 16 : 20)
        .background(Color.overdueBg, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }
}

#Preview("iPhone") {
    OverdueBanner(count: 45)
        .padding()
        .background(Color.appBackground)
}

#Preview("Mac") {
    OverdueBanner(count: 45, isRegular: true)
        .padding()
        .frame(width: 1000)
        .background(Color.appBackground)
}

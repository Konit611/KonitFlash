import SwiftUI

struct OverdueBanner: View {
    let count: Int
    var onTap: (() -> Void)?
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: isRegular ? 24 : 18))
                    .foregroundStyle(Color.overdueText)

                VStack(alignment: .leading, spacing: isRegular ? 2 : 0) {
                    Text("You have \(count) overdue cards !", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 24 : 18, weight: .bold))
                        .foregroundStyle(Color.overdueText)
                    if isRegular {
                        Text("It looks like you missed a few days. Don't worry, consistency is the key ! Let's clear some of that backlog now.", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.overdueText)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: isRegular ? 18 : 14, weight: .semibold))
                    .foregroundStyle(Color.overdueText)
                    .padding(isRegular ? 10 : 8)
                    .background(Color.white, in: Circle())
            }
            .padding(.horizontal, isRegular ? 24 : 16)
            .padding(.vertical, isRegular ? 16 : 20)
            .background(Color.overdueBg, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
        }
        .buttonStyle(.plain)
    }
}

#Preview("iPhone") {
    OverdueBanner(count: 45)
        .padding()
        .background(Color.appBackground)
}

#Preview("Mac") {
    OverdueBanner(count: 45)
        .environment(\.horizontalSizeClass, .regular)
        .padding()
        .frame(width: 1000)
        .background(Color.appBackground)
}

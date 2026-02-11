import SwiftUI

struct OverdueBanner: View {
    let count: Int
    var isRegular: Bool = false
    var onCatchUp: (() -> Void)?
    var onOverdueList: (() -> Void)?

    var body: some View {
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

            if isRegular {
                HStack(spacing: 12) {
                    Button {
                        onOverdueList?()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Overdue Cards", bundle: LanguageManager.shared.bundle)
                                .font(.system(size: 15))
                            Image(systemName: "list.bullet")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Color.overdueText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button {
                        onCatchUp?()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Catch Up Now", bundle: LanguageManager.shared.bundle)
                                .font(.system(size: 15))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(Color.overdueText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                VStack(spacing: 8) {
                    Button {
                        onCatchUp?()
                    } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.overdueText)
                    }
                    .buttonStyle(.plain)

                    Button {
                        onOverdueList?()
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.overdueText)
                            .frame(width: 28, height: 28)
                            .background(.white, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
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

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var onButtonTap: (() -> Void)?
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(spacing: isRegular ? 20 : 14) {
            Image(systemName: icon)
                .font(.system(size: isRegular ? 48 : 36))
                .foregroundStyle(.white.opacity(0.3))

            Text(title)
                .font(.system(size: isRegular ? 22 : 18, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))

            Text(message)
                .font(.system(size: isRegular ? 16 : 14))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            if let buttonTitle, let onButtonTap {
                Button {
                    onButtonTap()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                        Text(buttonTitle)
                            .font(.system(size: isRegular ? 17 : 15, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 28 : 20)
                    .padding(.vertical, isRegular ? 14 : 10)
                    .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isRegular ? 60 : 40)
    }
}

#Preview("iPhone") {
    EmptyStateView(
        icon: "rectangle.stack",
        title: "No Decks Yet",
        message: "Create your first deck to start learning",
        buttonTitle: "Create Deck",
        onButtonTap: {}
    )
    .background(Color.appBackground)
}

#Preview("Mac") {
    EmptyStateView(
        icon: "checkmark.circle",
        title: "All Caught Up!",
        message: "You've completed all reviews for today"
    )
    .frame(width: 800)
    .background(Color.appBackground)
}

import SwiftUI

struct AppHeaderView: View {
    var title: String?
    var showSettings: Bool = false
    var onDismiss: (() -> Void)?

    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        HStack {
            leadingContent

            Spacer()

            if let title {
                Text(title)
                    .font(.system(size: isRegular ? 24 : 20, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }

            trailingContent
        }
    }

    @ViewBuilder
    private var leadingContent: some View {
        if isRegular {
            HStack(spacing: 10) {
                logoCircle
                    .onTapGesture { onDismiss?() }
                Text("KONIT Flash")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
        } else if let onDismiss {
            Button {
                onDismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        } else {
            HStack(spacing: 10) {
                logoCircle
            }
        }
    }

    @ViewBuilder
    private var trailingContent: some View {
        if showSettings {
            Button {} label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: isRegular ? 22 : 18))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        } else if title != nil {
            // Invisible spacer for centering title
            Circle()
                .fill(.clear)
                .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
        }
    }

    private var logoCircle: some View {
        ZStack {
            Circle()
                .fill(Color.appBackground)
                .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                .overlay(
                    Circle().stroke(Color.learnedGreen.opacity(0.3), lineWidth: 1)
                )
            Image(systemName: "bolt.fill")
                .font(.system(size: isRegular ? 22 : 18, weight: .bold))
                .foregroundStyle(Color.learnedGreen)
        }
    }
}

#Preview("iPhone - Home") {
    AppHeaderView(showSettings: true)
        .padding()
        .background(Color.appBackground)
}

#Preview("iPhone - Detail") {
    AppHeaderView(showSettings: true, onDismiss: {})
        .padding()
        .background(Color.appBackground)
}

#Preview("iPhone - Form") {
    AppHeaderView(title: "Add Card", onDismiss: {})
        .padding()
        .background(Color.appBackground)
}

#Preview("Mac") {
    AppHeaderView(title: "Add Deck", showSettings: false, onDismiss: {})
        .padding(40)
        .frame(width: 1440)
        .background(Color.appBackground)
}

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
        if isRegular, onDismiss == nil {
            HStack(spacing: 10) {
                logoCircle
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
                        .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                    Image(systemName: "chevron.left")
                        .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        } else {
            logoCircle
        }
    }

    @ViewBuilder
    private var trailingContent: some View {
        if showSettings {
            NavigationLink(value: NavigationRoute.settings) {
                ZStack {
                    RoundedRectangle(cornerRadius: isRegular ? 12 : 9)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: isRegular ? 12 : 9)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: isRegular ? 22 : 18))
                        .foregroundStyle(.white)
                }
            }
        } else if title != nil {
            // Invisible spacer for centering title
            RoundedRectangle(cornerRadius: isRegular ? 12 : 9)
                .fill(.clear)
                .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
        }
    }

    private var logoCircle: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFill()
            .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
            .clipShape(RoundedRectangle(cornerRadius: isRegular ? 12 : 9))
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

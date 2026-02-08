import SwiftUI

struct SettingsView: View {
    @StateObject private var presenter: SettingsPresenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    init() {
        _presenter = StateObject(wrappedValue: SettingsPresenter())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 24 : 16) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)

                languageSection
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(
            title: String(localized: "Settings", bundle: LanguageManager.shared.bundle),
            onDismiss: { dismiss() }
        )
    }

    // MARK: - Language Section

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: isRegular ? 20 : 14) {
            Text(String(localized: "Language", bundle: LanguageManager.shared.bundle))
                .font(.system(size: isRegular ? 18 : 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))

            VStack(spacing: 0) {
                ForEach(Array(presenter.viewState.languages.enumerated()), id: \.element.id) { index, language in
                    Button {
                        presenter.selectLanguage(language.id)
                    } label: {
                        HStack {
                            Text(language.name)
                                .font(.system(size: isRegular ? 18 : 16))
                                .foregroundStyle(.black)

                            Spacer()

                            if language.isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: isRegular ? 18 : 16, weight: .semibold))
                                    .foregroundStyle(Color.learnedGreen)
                            }
                        }
                        .padding(.horizontal, isRegular ? 24 : 18)
                        .padding(.vertical, isRegular ? 18 : 14)
                    }

                    if index < presenter.viewState.languages.count - 1 {
                        Divider()
                            .padding(.horizontal, isRegular ? 24 : 18)
                    }
                }
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
        }
    }
}

#Preview("iPhone") {
    NavigationStack {
        SettingsView()
    }
}

#Preview("Mac") {
    NavigationStack {
        SettingsView()
    }
    .frame(width: 1440, height: 900)
}

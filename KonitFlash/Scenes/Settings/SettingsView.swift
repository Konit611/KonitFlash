import SwiftUI

struct SettingsView: View {
    @StateObject private var presenter = SettingsPresenter()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 24 : 16) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)

                languageSection

                sessionCardLimitSection
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure() }
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(
            title: String(localized: "Settings", bundle: LanguageManager.shared.bundle),
            onDismiss: { dismiss() }
        )
    }

    // MARK: - Session Card Limit Section

    private var sessionCardLimitSection: some View {
        VStack(alignment: .leading, spacing: isRegular ? 20 : 14) {
            Text(String(localized: "Cards per Session", bundle: LanguageManager.shared.bundle))
                .font(.system(size: isRegular ? 18 : 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))

            HStack {
                Text(presenter.viewState.sessionCardLimitDisplay)
                    .font(.system(size: isRegular ? 18 : 16, weight: .semibold))
                    .foregroundStyle(.black)

                Spacer()

                HStack(spacing: 0) {
                    Button {
                        let current = presenter.viewState.sessionCardLimit
                        if current > 10 {
                            presenter.selectSessionCardLimit(current - 10)
                        } else if current > 0 {
                            presenter.selectSessionCardLimit(0)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: isRegular ? 16 : 14, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: isRegular ? 44 : 38, height: isRegular ? 38 : 32)
                    }
                    .disabled(presenter.viewState.sessionCardLimit == 0)

                    Divider()
                        .frame(height: isRegular ? 20 : 16)

                    Button {
                        let current = presenter.viewState.sessionCardLimit
                        if current == 0 {
                            presenter.selectSessionCardLimit(10)
                        } else {
                            presenter.selectSessionCardLimit(current + 10)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: isRegular ? 16 : 14, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: isRegular ? 44 : 38, height: isRegular ? 38 : 32)
                    }
                }
                .background(Color(hex: 0xF0F0F0), in: RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, isRegular ? 24 : 18)
            .padding(.vertical, isRegular ? 16 : 12)
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
        }
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
                        WidgetDataService.writeWidgetData(from: modelContext)
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

import Combine
import Foundation

final class SettingsPresenter: ObservableObject {
    @Published var viewState = SettingsViewState()

    private let interactor: SettingsInteractor

    init(interactor: SettingsInteractor = SettingsInteractor()) {
        self.interactor = interactor
        loadData()
    }

    func loadData() {
        let data = interactor.fetchSettings()
        let limit = data.sessionCardLimit
        let display = limit > 0
            ? "\(limit)"
            : String(localized: "Unlimited", bundle: LanguageManager.shared.bundle)

        viewState = SettingsViewState(
            languages: data.availableLanguages.map { lang in
                LanguageOption(
                    id: lang.code,
                    name: lang.name,
                    isSelected: lang.code == data.selectedLanguageCode
                )
            },
            selectedCode: data.selectedLanguageCode,
            sessionCardLimit: limit,
            sessionCardLimitDisplay: display
        )
    }

    func selectLanguage(_ code: String) {
        interactor.setLanguage(code)
        loadData()
    }

    func selectSessionCardLimit(_ limit: Int) {
        let clamped = max(limit, 0)
        interactor.setSessionCardLimit(clamped)
        loadData()
    }
}

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

        viewState = SettingsViewState(
            languages: data.availableLanguages.map { lang in
                LanguageOption(
                    id: lang.code,
                    name: lang.name,
                    isSelected: lang.code == data.selectedLanguageCode
                )
            },
            selectedCode: data.selectedLanguageCode
        )
    }

    func selectLanguage(_ code: String) {
        interactor.setLanguage(code)
        loadData()
    }
}

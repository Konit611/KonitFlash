import Combine
import Foundation

final class SettingsPresenter: ObservableObject {
    @Published var viewState = SettingsViewState()

    private var interactor: SettingsInteractor?

    func configure() {
        if interactor != nil {
            loadData()
            return
        }
        self.interactor = SettingsInteractor()
        loadData()
    }

    func loadData() {
        guard let interactor else { return }
        let data = interactor.fetchSettings()
        let limit = data.sessionCardLimit
        let isCustom = !data.presetLimitValues.contains(limit)

        let bundle = LanguageManager.shared.bundle
        let unlimitedLabel = String(localized: "Unlimited", bundle: bundle)

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
            presetLimits: data.presetLimitValues.map { value in
                PresetLimit(
                    id: value,
                    label: value == 0 ? unlimitedLabel : "\(value)",
                    isSelected: !isCustom && value == limit
                )
            },
            isCustomSelected: isCustom,
            customLimitText: isCustom ? "\(limit)" : "",
            appVersion: data.appVersion,
            buildNumber: data.buildNumber
        )
    }

    func selectLanguage(_ code: String) {
        interactor?.setLanguage(code)
        loadData()
    }

    func selectPresetLimit(_ value: Int) {
        let clamped = max(value, 0)
        interactor?.setSessionCardLimit(clamped)
        loadData()
    }

    func selectCustom() {
        viewState.isCustomSelected = true
        for i in viewState.presetLimits.indices {
            viewState.presetLimits[i].isSelected = false
        }
    }

    func setCustomLimit(_ text: String) {
        guard let value = Int(text), value > 0 else { return }
        interactor?.setSessionCardLimit(value)
        loadData()
    }
}

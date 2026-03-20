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
            buildNumber: data.buildNumber,
            privacyPolicyURL: privacyPolicyURL()
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

    private func privacyPolicyURL() -> URL {
        let code = LanguageManager.shared.selectedLanguage
        let urlString: String
        switch code {
        case "ko":
            urlString = "https://ripe-chicory-8d6.notion.site/KONIT-Flash-329a2833b7de81bc8343c49421212e0b"
        case "ja":
            urlString = "https://ripe-chicory-8d6.notion.site/KONIT-Flash-329a2833b7de8127ae16f5d1bcc8e2ab"
        case "zh-Hans":
            urlString = "https://ripe-chicory-8d6.notion.site/KONIT-Flash-329a2833b7de8078b974c69bbc4531ef"
        default:
            urlString = "https://ripe-chicory-8d6.notion.site/Privacy-Policy-KONIT-Flash-329a2833b7de81ba9ec2eaa294cd5fa0"
        }
        return URL(string: urlString)!
    }
}

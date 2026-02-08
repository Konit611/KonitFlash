import Foundation

struct SettingsData {
    let selectedLanguageCode: String
    let availableLanguages: [(code: String, name: String)]
}

final class SettingsInteractor {
    func fetchSettings() -> SettingsData {
        let selected = LanguageManager.shared.selectedLanguage

        let languages: [(code: String, name: String)] = [
            ("system", String(localized: "System Default", bundle: LanguageManager.shared.bundle)),
            ("en", "English"),
            ("ko", "한국어"),
            ("ja", "日本語"),
            ("zh-Hans", "简体中文")
        ]

        return SettingsData(
            selectedLanguageCode: selected,
            availableLanguages: languages
        )
    }

    func setLanguage(_ code: String) {
        LanguageManager.shared.setLanguage(code)
    }
}

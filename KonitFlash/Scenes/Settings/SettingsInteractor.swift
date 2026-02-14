import Foundation

struct SettingsData {
    let selectedLanguageCode: String
    let availableLanguages: [(code: String, name: String)]
    let sessionCardLimit: Int
}

final class SettingsInteractor {
    static let sessionCardLimitKey = "sessionCardLimit"

    func fetchSettings() -> SettingsData {
        let selected = LanguageManager.shared.selectedLanguage

        let languages: [(code: String, name: String)] = [
            ("system", String(localized: "System Default", bundle: LanguageManager.shared.bundle)),
            ("en", "English"),
            ("ko", "한국어"),
            ("ja", "日本語"),
            ("zh-Hans", "简体中文")
        ]

        let limit = Self.currentSessionCardLimit()

        return SettingsData(
            selectedLanguageCode: selected,
            availableLanguages: languages,
            sessionCardLimit: limit
        )
    }

    static func currentSessionCardLimit() -> Int {
        let stored = UserDefaults.standard.object(forKey: sessionCardLimitKey) as? Int
        return stored ?? 20
    }

    func setLanguage(_ code: String) {
        LanguageManager.shared.setLanguage(code)
    }

    func setSessionCardLimit(_ limit: Int) {
        UserDefaults.standard.set(limit, forKey: Self.sessionCardLimitKey)
    }
}

import Combine
import Foundation

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published private(set) var selectedLanguage: String
    @Published private(set) var locale: Locale
    @Published private(set) var bundle: Bundle

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "system"
        self.selectedLanguage = saved
        self.locale = .current
        self.bundle = .main
        updateLocaleAndBundle()
    }

    func setLanguage(_ code: String) {
        selectedLanguage = code
        UserDefaults.standard.set(code, forKey: "appLanguage")
        updateLocaleAndBundle()
    }

    private func updateLocaleAndBundle() {
        if selectedLanguage == "system" {
            locale = .current
            bundle = .main
        } else if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
                  let langBundle = Bundle(path: path) {
            locale = Locale(identifier: selectedLanguage)
            bundle = langBundle
        } else {
            locale = .current
            bundle = .main
        }
    }
}

import Foundation

struct SettingsViewState {
    var languages: [LanguageOption] = []
    var selectedCode: String = "system"

    // Cards per Session
    var sessionCardLimit: Int = 20
    var presetLimits: [PresetLimit] = []
    var isCustomSelected: Bool = false
    var customLimitText: String = ""

    // App Info
    var appVersion: String = ""
    var buildNumber: String = ""
    var privacyPolicyURL: URL = URL(string: "https://example.com/privacy")!
}

struct LanguageOption: Identifiable {
    let id: String
    let name: String
    var isSelected: Bool
}

struct PresetLimit: Identifiable {
    let id: Int // the limit value (0 = unlimited)
    let label: String
    var isSelected: Bool
}

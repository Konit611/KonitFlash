import Foundation

struct SettingsViewState {
    var languages: [LanguageOption] = []
    var selectedCode: String = "system"
    var sessionCardLimit: Int = 20
    var sessionCardLimitDisplay: String = "20"
}

struct LanguageOption: Identifiable {
    let id: String
    let name: String
    var isSelected: Bool
}

import Foundation

struct SettingsViewState {
    var languages: [LanguageOption] = []
    var selectedCode: String = "system"
}

struct LanguageOption: Identifiable {
    let id: String
    let name: String
    var isSelected: Bool
}

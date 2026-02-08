import Foundation

struct AddDeckViewState {
    var isEditMode: Bool = false
    var name: String = ""
    var description: String = ""
    var selectedColorTag: ColorTag = .pink
    var isSaveEnabled: Bool = false
    var headerTitle: String = String(localized: "New Deck", bundle: LanguageManager.shared.bundle)
    var buttonTitle: String = String(localized: "Create Deck", bundle: LanguageManager.shared.bundle)
}

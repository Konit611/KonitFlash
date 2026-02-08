import Foundation

struct AddCardViewState {
    var isEditMode: Bool = false
    var deckName: String = ""
    var front: String = ""
    var back: String = ""
    var isSaveEnabled: Bool = false
    var headerTitle: String = String(localized: "Add Card", bundle: LanguageManager.shared.bundle)
    var buttonTitle: String = String(localized: "Add Card", bundle: LanguageManager.shared.bundle)
}

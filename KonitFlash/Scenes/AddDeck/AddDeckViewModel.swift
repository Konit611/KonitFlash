import Foundation

struct AddDeckViewState {
    var isEditMode: Bool = false
    var name: String = ""
    var description: String = ""
    var selectedColorTag: ColorTag = .pink
    var isSaveEnabled: Bool = false
    var headerTitle: String = "New Deck"
    var buttonTitle: String = "Create Deck"
}

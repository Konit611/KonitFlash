import Combine
import Foundation

final class AddDeckPresenter: ObservableObject {
    @Published var viewState = AddDeckViewState()

    private let interactor: AddDeckInteractor
    private let editingDeckID: UUID?

    init(interactor: AddDeckInteractor = AddDeckInteractor(), editingDeckID: UUID? = nil) {
        self.interactor = interactor
        self.editingDeckID = editingDeckID

        if let editingDeckID {
            loadEditData(deckID: editingDeckID)
        }
    }

    func updateName(_ name: String) {
        viewState.name = name
        viewState.isSaveEnabled = !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func updateDescription(_ description: String) {
        viewState.description = description
    }

    func updateColorTag(_ tag: ColorTag) {
        viewState.selectedColorTag = tag
    }

    func saveDeck() {
        let input = AddDeckInput(
            name: viewState.name.trimmingCharacters(in: .whitespaces),
            description: viewState.description.trimmingCharacters(in: .whitespaces),
            colorTag: viewState.selectedColorTag
        )

        if let editingDeckID {
            interactor.updateDeck(deckID: editingDeckID, input: input)
        } else {
            interactor.saveDeck(input)
        }
    }

    private func loadEditData(deckID: UUID) {
        let data = interactor.fetchDeck(deckID: deckID)
        viewState.isEditMode = true
        viewState.name = data.name
        viewState.description = data.description
        viewState.selectedColorTag = data.colorTag
        viewState.isSaveEnabled = true
        viewState.headerTitle = "Edit Deck"
        viewState.buttonTitle = "Save Changes"
    }
}

import Combine
import Foundation

final class AddCardPresenter: ObservableObject {
    @Published var viewState = AddCardViewState()

    private let interactor: AddCardInteractor
    private let deckID: UUID
    private let editingCardID: UUID?

    init(interactor: AddCardInteractor = AddCardInteractor(), deckID: UUID, editingCardID: UUID? = nil) {
        self.interactor = interactor
        self.deckID = deckID
        self.editingCardID = editingCardID

        if let editingCardID {
            loadEditData(cardID: editingCardID)
        } else {
            loadData()
        }
    }

    func loadData() {
        let data = interactor.fetchDeckInfo(deckID: deckID)
        viewState.deckName = data.deckName
    }

    func updateFront(_ text: String) {
        viewState.front = text
        updateSaveEnabled()
    }

    func updateBack(_ text: String) {
        viewState.back = text
        updateSaveEnabled()
    }

    func saveCard() {
        let input = AddCardInput(
            deckID: deckID,
            front: viewState.front.trimmingCharacters(in: .whitespaces),
            back: viewState.back.trimmingCharacters(in: .whitespaces)
        )

        if let editingCardID {
            interactor.updateCard(cardID: editingCardID, input: input)
        } else {
            interactor.saveCard(input)
        }
    }

    private func updateSaveEnabled() {
        let frontValid = !viewState.front.trimmingCharacters(in: .whitespaces).isEmpty
        let backValid = !viewState.back.trimmingCharacters(in: .whitespaces).isEmpty
        viewState.isSaveEnabled = frontValid && backValid
    }

    private func loadEditData(cardID: UUID) {
        let data = interactor.fetchCard(deckID: deckID, cardID: cardID)
        viewState.isEditMode = true
        viewState.deckName = data.deckName
        viewState.front = data.front
        viewState.back = data.back
        viewState.isSaveEnabled = true
        let bundle = LanguageManager.shared.bundle
        viewState.headerTitle = String(localized: "Edit Card", bundle: bundle)
        viewState.buttonTitle = String(localized: "Save Changes", bundle: bundle)
    }
}

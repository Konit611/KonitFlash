import Combine
import Foundation
import SwiftData

final class AddCardPresenter: ObservableObject {
    @Published var viewState = AddCardViewState()

    private var interactor: AddCardInteractor?
    private var deckID: UUID?
    private var editingCardID: UUID?

    func configure(modelContext: ModelContext, deckID: UUID, editingCardID: UUID? = nil) {
        self.deckID = deckID
        self.editingCardID = editingCardID

        if interactor != nil {
            if let editingCardID {
                loadEditData(cardID: editingCardID)
            } else {
                loadData()
            }
            return
        }
        self.interactor = AddCardInteractor(modelContext: modelContext)

        if let editingCardID {
            loadEditData(cardID: editingCardID)
        } else {
            loadData()
        }
    }

    func loadData() {
        guard let interactor, let deckID else { return }
        guard let data = interactor.fetchDeckInfo(deckID: deckID) else { return }
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

    @discardableResult
    func createCard() -> Bool {
        guard let interactor else { return false }
        return interactor.saveCard(buildInput())
    }

    @discardableResult
    func updateCard() -> Bool {
        guard let interactor, let editingCardID else { return false }
        return interactor.updateCard(cardID: editingCardID, input: buildInput())
    }

    private func buildInput() -> AddCardInput {
        guard let deckID else { return AddCardInput(deckID: UUID(), front: "", back: "") }
        return AddCardInput(
            deckID: deckID,
            front: viewState.front.trimmingCharacters(in: .whitespaces),
            back: viewState.back.trimmingCharacters(in: .whitespaces)
        )
    }

    private func updateSaveEnabled() {
        let frontValid = !viewState.front.trimmingCharacters(in: .whitespaces).isEmpty
        let backValid = !viewState.back.trimmingCharacters(in: .whitespaces).isEmpty
        viewState.isSaveEnabled = frontValid && backValid
    }

    private func loadEditData(cardID: UUID) {
        guard let interactor, let deckID else { return }
        guard let data = interactor.fetchCard(deckID: deckID, cardID: cardID) else { return }
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

import Combine
import Foundation
import SwiftData

final class AddDeckPresenter: ObservableObject {
    @Published var viewState = AddDeckViewState()

    private var interactor: AddDeckInteractor?
    private var editingDeckID: UUID?

    func configure(modelContext: ModelContext, editingDeckID: UUID? = nil) {
        self.editingDeckID = editingDeckID

        if interactor != nil {
            if let editingDeckID { loadEditData(deckID: editingDeckID) }
            return
        }
        self.interactor = AddDeckInteractor(modelContext: modelContext)

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

    func createDeck() {
        guard let interactor else { return }
        interactor.saveDeck(buildInput())
    }

    func updateDeck() {
        guard let interactor, let editingDeckID else { return }
        interactor.updateDeck(deckID: editingDeckID, input: buildInput())
    }

    private func buildInput() -> AddDeckInput {
        AddDeckInput(
            name: viewState.name.trimmingCharacters(in: .whitespaces),
            description: viewState.description.trimmingCharacters(in: .whitespaces),
            colorTag: viewState.selectedColorTag
        )
    }

    private func loadEditData(deckID: UUID) {
        guard let data = interactor?.fetchDeck(deckID: deckID) else { return }
        viewState.isEditMode = true
        viewState.name = data.name
        viewState.description = data.description
        viewState.selectedColorTag = data.colorTag
        viewState.isSaveEnabled = true
        let bundle = LanguageManager.shared.bundle
        viewState.headerTitle = String(localized: "Edit Deck", bundle: bundle)
        viewState.buttonTitle = String(localized: "Save Changes", bundle: bundle)
    }
}

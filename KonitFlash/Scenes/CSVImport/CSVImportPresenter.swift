import Combine
import Foundation
import SwiftData

final class CSVImportPresenter: ObservableObject {
    @Published var viewState = CSVImportViewState()

    private var interactor: CSVImportInteractor?
    private var deckID: UUID?
    private var parsedCards: [(front: String, back: String)] = []
    private var duplicates: Set<String> = []

    func configure(modelContext: ModelContext, deckID: UUID) {
        self.deckID = deckID

        if interactor != nil { return }
        self.interactor = CSVImportInteractor(modelContext: modelContext)

        viewState.deckName = interactor?.fetchDeckName(deckID: deckID) ?? ""
    }

    func handleFileSelected(url: URL) {
        guard let interactor, let deckID else { return }

        let result = interactor.parseFile(at: url)

        if result.cards.isEmpty {
            viewState.phase = .error
            viewState.errorMessage = result.errors.first ?? "No valid cards found in file"
            viewState.errors = result.errors
            return
        }

        parsedCards = result.cards
        duplicates = interactor.findDuplicates(in: deckID, fronts: result.cards.map { $0.front })

        viewState.phase = .preview
        viewState.previewCards = Array(result.cards.prefix(5))
        viewState.totalCount = result.cards.count
        viewState.skippedCount = result.skippedRows
        viewState.duplicateCount = duplicates.count
        viewState.errors = result.errors
    }

    func confirmImport() {
        guard let interactor, let deckID else { return }

        viewState.phase = .importing

        let imported = interactor.importCards(into: deckID, cards: parsedCards, skipDuplicates: duplicates)

        viewState.importedCount = imported
        viewState.phase = .done
    }

    func handleFileError() {
        viewState.phase = .error
        viewState.errorMessage = "Failed to access the selected file"
    }

    func resetToFileSelect() {
        viewState = CSVImportViewState()
        if let deckID {
            viewState.deckName = interactor?.fetchDeckName(deckID: deckID) ?? ""
        }
        parsedCards = []
        duplicates = []
    }
}

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

        if interactor != nil {
            viewState.deckName = interactor?.fetchDeckName(deckID: deckID) ?? ""
            return
        }
        self.interactor = CSVImportInteractor(modelContext: modelContext)

        viewState.deckName = interactor?.fetchDeckName(deckID: deckID) ?? ""
    }

    func handleFileSelected(url: URL) {
        guard let interactor, let deckID else { return }

        let result = interactor.parseFile(at: url)

        if result.cards.isEmpty {
            viewState.phase = .error
            let bundle = LanguageManager.shared.bundle
            viewState.errorMessage = result.errors.first ?? String(localized: "No valid cards found in file", bundle: bundle)
            viewState.errors = result.errors
            return
        }

        parsedCards = result.cards
        duplicates = interactor.findDuplicates(in: deckID, fronts: result.cards.map { $0.front })

        viewState.phase = .preview
        viewState.previewCards = result.cards.prefix(5).enumerated().map { index, card in
            PreviewCardData(id: index, front: card.front, back: card.back)
        }
        viewState.totalCount = result.cards.count
        viewState.skippedCount = result.skippedRows
        viewState.duplicateCount = duplicates.count
        viewState.errors = result.errors
    }

    func confirmImport() {
        guard let interactor, let deckID else { return }

        viewState.phase = .importing

        let cards = parsedCards
        let dupes = duplicates
        Task { @MainActor in
            let imported = interactor.importCards(into: deckID, cards: cards, skipDuplicates: dupes)
            viewState.importedCount = imported
            viewState.phase = .done
        }
    }

    func handleFileError() {
        viewState.phase = .error
        viewState.errorMessage = String(localized: "Failed to access the selected file", bundle: LanguageManager.shared.bundle)
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

import Combine
import SwiftUI
import SwiftData

final class OverdueListPresenter: ObservableObject {
    @Published var viewState = OverdueListViewState()

    private var interactor: OverdueListInteractor?

    func configure(modelContext: ModelContext) {
        if interactor != nil {
            loadData()
            return
        }
        self.interactor = OverdueListInteractor(modelContext: modelContext)
        loadData()
    }

    func loadData() {
        guard let interactor else { return }
        let results = interactor.fetchOverdueDecks()

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let bundle = LanguageManager.shared.bundle

        let groups = results.map { deck in
            OverdueDeckGroup(
                id: deck.deckID,
                deckName: deck.deckName,
                cards: deck.cards.map { card in
                    OverdueCardRowData(
                        id: card.id,
                        front: card.front,
                        dueDateText: String(localized: "Due: \(formatter.string(from: card.dueDate))", bundle: bundle),
                        box: card.box
                    )
                }
            )
        }

        viewState = OverdueListViewState(
            deckGroups: groups,
            isEmpty: groups.isEmpty
        )
    }
}

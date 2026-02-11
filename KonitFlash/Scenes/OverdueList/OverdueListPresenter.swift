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
        let results = interactor.fetchOverdueCards()

        let formatter = DateFormatter()
        formatter.dateStyle = .short

        let bundle = LanguageManager.shared.bundle
        let cards = results.map { item in
            OverdueCardRowData(
                id: item.card.id,
                front: item.card.front,
                deckName: item.deckName,
                dueDateText: String(localized: "Due: \(formatter.string(from: item.card.dueDate))", bundle: bundle),
                box: item.card.box
            )
        }

        viewState = OverdueListViewState(
            cards: cards,
            isEmpty: cards.isEmpty
        )
    }
}

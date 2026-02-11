import Foundation

struct OverdueListViewState {
    var cards: [OverdueCardRowData] = []
    var isEmpty: Bool = true
}

struct OverdueCardRowData: Identifiable {
    let id: UUID
    let front: String
    let deckName: String
    let dueDateText: String
    let box: Int
}

import Foundation

struct OverdueListViewState {
    var deckGroups: [OverdueDeckGroup] = []
    var isEmpty: Bool = true
}

struct OverdueDeckGroup: Identifiable {
    let id: UUID
    let deckName: String
    let cards: [OverdueCardRowData]
}

struct OverdueCardRowData: Identifiable {
    let id: UUID
    let front: String
    let dueDateText: String
    let box: Int
}

import SwiftUI

struct DeckDetailViewState {
    var deckName: String = ""
    var deckDescription: String = ""
    var dueTodayCount: Int = 0
    var totalCards: String = "0"
    var progress: Double = 0
    var progressPercent: String = "0%"
    var progressColor: Color = .streakPink
    var newCount: String = "0"
    var learningCount: String = "0"
    var reviewedCount: String = "0"
    var cards: [CardRowData] = []
    var isEmpty: Bool = true
}

struct CardRowData: Identifiable {
    let id: UUID
    let name: String
    let dueDateText: String
    let box: Int
    let isNew: Bool
    let isDue: Bool
}

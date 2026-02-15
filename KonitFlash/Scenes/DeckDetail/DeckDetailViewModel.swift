import SwiftUI

enum CardFilter: String, CaseIterable {
    case all = "All"
    case due = "Due"
    case newCards = "New"
    case learned = "Learned"

    var localizedLabel: String {
        let bundle = LanguageManager.shared.bundle
        switch self {
        case .all: return String(localized: "All", bundle: bundle)
        case .due: return String(localized: "Due", bundle: bundle)
        case .newCards: return String(localized: "New", bundle: bundle)
        case .learned: return String(localized: "Learned", bundle: bundle)
        }
    }
}

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

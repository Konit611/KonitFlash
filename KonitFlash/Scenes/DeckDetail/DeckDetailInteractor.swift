import Foundation

struct DeckDetailData {
    let deck: Deck
    let newCount: Int
    let learningCount: Int
    let reviewedCount: Int
    let dueTodayCount: Int
    let cards: [Card]
}

final class DeckDetailInteractor {
    func fetchDeckDetail(deckID: UUID) -> DeckDetailData {
        let deck = Deck(
            id: deckID,
            name: "English Vocabulary",
            description: "Essential Words for daily conservation",
            progress: 0.6,
            totalCards: 126,
            dueCards: 17,
            estimatedMinutes: 5,
            colorTag: .pink
        )

        let baseDate = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 28))!

        let cards = (0..<5).map { _ in
            Card(front: "English", dueDate: baseDate, box: 5)
        }

        return DeckDetailData(
            deck: deck,
            newCount: 6,
            learningCount: 12,
            reviewedCount: 121,
            dueTodayCount: 12,
            cards: cards
        )
    }
}

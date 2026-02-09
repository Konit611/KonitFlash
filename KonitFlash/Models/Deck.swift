import Foundation
import SwiftData

enum ColorTag: String, Codable, CaseIterable {
    case pink
    case green
}

@Model final class Deck {
    var id: UUID = UUID()
    var name: String = ""
    var deckDescription: String = ""
    var colorTag: String = "pink"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \Card.deck)
    var cards: [Card]?

    var totalCards: Int { (cards ?? []).count }

    var dueCards: Int {
        let now = Date()
        return (cards ?? []).filter { $0.dueDate <= now }.count
    }

    var progress: Double {
        let allCards = cards ?? []
        guard !allCards.isEmpty else { return 0 }
        let learned = allCards.filter { $0.repetitions > 0 }.count
        return Double(learned) / Double(allCards.count)
    }

    var estimatedMinutes: Int {
        guard dueCards > 0 else { return 0 }
        return max(1, dueCards / 3)
    }

    var colorTagEnum: ColorTag {
        get { ColorTag(rawValue: colorTag) ?? .pink }
        set { colorTag = newValue.rawValue }
    }

    init(name: String = "", deckDescription: String = "", colorTag: ColorTag = .pink) {
        self.id = UUID()
        self.name = name
        self.deckDescription = deckDescription
        self.colorTag = colorTag.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

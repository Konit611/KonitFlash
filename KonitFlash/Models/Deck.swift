import Foundation

enum ColorTag: String {
    case pink
    case green
}

struct Deck: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let progress: Double
    let totalCards: Int
    let dueCards: Int
    let estimatedMinutes: Int
    let colorTag: ColorTag

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        progress: Double,
        totalCards: Int,
        dueCards: Int,
        estimatedMinutes: Int,
        colorTag: ColorTag
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.progress = progress
        self.totalCards = totalCards
        self.dueCards = dueCards
        self.estimatedMinutes = estimatedMinutes
        self.colorTag = colorTag
    }
}

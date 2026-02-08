import Foundation

enum NavigationRoute: Hashable {
    case deckDetail(UUID)
    case addDeck
    case editDeck(deckID: UUID)
    case addCard(deckID: UUID)
    case editCard(deckID: UUID, cardID: UUID)
    case flashCard(deckID: UUID)
    case settings
}

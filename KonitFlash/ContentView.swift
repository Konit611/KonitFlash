import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: NavigationRoute.self) { route in
                    switch route {
                    case .deckDetail(let id):
                        DeckDetailView(deckID: id)
                    case .addDeck:
                        AddDeckView()
                    case .editDeck(let id):
                        AddDeckView(editingDeckID: id)
                    case .addCard(let id):
                        AddCardView(deckID: id)
                    case .editCard(let deckID, let cardID):
                        AddCardView(deckID: deckID, editingCardID: cardID)
                    case .flashCard(let id):
                        FlashCardView(deckID: id)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI
import SwiftData

struct ContentView: View {
    @Binding var path: NavigationPath

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
                    case .settings:
                        SettingsView()
                    case .csvImport(let deckID):
                        CSVImportView(deckID: deckID)
                    case .overdueList:
                        OverdueListView()
                    }
                }
        }
    }
}

#Preview {
    ContentView(path: .constant(NavigationPath()))
        .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

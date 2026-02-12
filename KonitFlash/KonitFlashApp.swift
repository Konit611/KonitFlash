import SwiftUI
import SwiftData

@main
struct KonitFlashApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    @State private var path = NavigationPath()

    let container: ModelContainer

    init() {
        let schema = Schema([Deck.self, Card.self, StudyLog.self])
        do {
            let cloudConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
            container = try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
            do {
                let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
                container = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(path: $path)
                .environment(\.locale, languageManager.locale)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(container)
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "konitflash" else { return }

        switch url.host {
        case "study":
            let pathComponent = url.pathComponents.dropFirst().first ?? ""
            guard let deckID = UUID(uuidString: pathComponent) else { return }
            path = NavigationPath()
            path.append(NavigationRoute.flashCard(deckID: deckID))
        default:
            path = NavigationPath()
        }
    }
}

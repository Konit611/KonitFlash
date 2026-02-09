//
//  KonitFlashApp.swift
//  KonitFlash
//
//  Created by GEUNIL on 2026/02/01.
//

import SwiftUI
import SwiftData

@main
struct KonitFlashApp: App {
    @StateObject private var languageManager = LanguageManager.shared

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
            ContentView()
                .environment(\.locale, languageManager.locale)
        }
        .modelContainer(container)
    }
}

//
//  KonitFlashApp.swift
//  KonitFlash
//
//  Created by GEUNIL on 2026/02/01.
//

import SwiftUI

@main
struct KonitFlashApp: App {
    @StateObject private var languageManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, languageManager.locale)
        }
    }
}

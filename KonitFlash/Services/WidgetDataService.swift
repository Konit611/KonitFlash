import Foundation
import os
import SwiftData
import WidgetKit

private let logger = Logger(subsystem: "geunil.KonitFlash", category: "WidgetDataService")

struct WidgetDeckInfo: Codable, Equatable {
    let id: UUID
    let name: String
    let colorTag: String
    let dueCards: Int
    let totalCards: Int
}

struct WidgetDeckSnapshot: Codable {
    let id: UUID
    let name: String
    let colorTag: String
    let totalCards: Int
    let cardDueDates: [Date]
}

struct WidgetRawData: Codable {
    let decks: [WidgetDeckSnapshot]
    let streakDays: Int
    let languageCode: String
}

struct WidgetData: Codable, Equatable {
    let dueCardCount: Int
    let streakDays: Int
    let topDecks: [WidgetDeckInfo]
    let mostUrgentDeckID: UUID?
    let updatedAt: Date
    let languageCode: String

    static func == (lhs: WidgetData, rhs: WidgetData) -> Bool {
        lhs.dueCardCount == rhs.dueCardCount
        && lhs.streakDays == rhs.streakDays
        && lhs.topDecks == rhs.topDecks
        && lhs.mostUrgentDeckID == rhs.mostUrgentDeckID
        && lhs.languageCode == rhs.languageCode
    }
}

enum WidgetDataService {
    static let suiteName = "group.geunil.KonitFlash"
    static let dataKey = "widgetData"
    static let rawDataKey = "widgetRawData"

    static func writeWidgetData(from modelContext: ModelContext) {
        let decks = fetchDecks(from: modelContext)
        let logs = fetchRecentLogs(from: modelContext)

        let now = Date()
        let allCards = decks.flatMap { $0.cards ?? [] }
        let dueCardCount = allCards.filter { $0.dueDate <= now }.count
        let streakDays = StudyLog.computeStreak(from: logs)

        let sortedDecks = decks
            .map { deck -> WidgetDeckInfo in
                let cards = deck.cards ?? []
                let due = cards.filter { $0.dueDate <= now }.count
                return WidgetDeckInfo(
                    id: deck.id,
                    name: deck.name,
                    colorTag: deck.colorTag,
                    dueCards: due,
                    totalCards: cards.count
                )
            }
            .sorted { $0.dueCards > $1.dueCards }

        let topDecks = Array(sortedDecks.prefix(3))
        let mostUrgentDeckID = sortedDecks.first(where: { $0.dueCards > 0 })?.id

        let languageCode = LanguageManager.shared.selectedLanguage

        let data = WidgetData(
            dueCardCount: dueCardCount,
            streakDays: streakDays,
            topDecks: topDecks,
            mostUrgentDeckID: mostUrgentDeckID,
            updatedAt: now,
            languageCode: languageCode
        )

        guard let defaults = UserDefaults(suiteName: suiteName) else { return }

        if let previousData = defaults.data(forKey: dataKey),
           let previous = try? JSONDecoder().decode(WidgetData.self, from: previousData),
           previous == data {
            return
        }

        do {
            let encoded = try JSONEncoder().encode(data)
            defaults.set(encoded, forKey: dataKey)
        } catch {
            logger.error("Failed to encode widget data: \(error)")
            return
        }

        let snapshots = decks.map { deck -> WidgetDeckSnapshot in
            let cards = deck.cards ?? []
            return WidgetDeckSnapshot(
                id: deck.id,
                name: deck.name,
                colorTag: deck.colorTag,
                totalCards: cards.count,
                cardDueDates: cards.map { $0.dueDate }
            )
        }

        let rawData = WidgetRawData(
            decks: snapshots,
            streakDays: streakDays,
            languageCode: languageCode
        )

        do {
            let encodedRaw = try JSONEncoder().encode(rawData)
            defaults.set(encodedRaw, forKey: rawDataKey)
        } catch {
            logger.error("Failed to encode widget raw data: \(error)")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Private

    private static func fetchDecks(from modelContext: ModelContext) -> [Deck] {
        let descriptor = FetchDescriptor<Deck>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private static func fetchRecentLogs(from modelContext: ModelContext) -> [StudyLog] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<StudyLog>(
            predicate: #Predicate { $0.studiedAt >= cutoff }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

}

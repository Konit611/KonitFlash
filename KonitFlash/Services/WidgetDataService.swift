import Foundation
import SwiftData
import WidgetKit

struct WidgetDeckInfo: Codable {
    let id: UUID
    let name: String
    let colorTag: String
    let dueCards: Int
    let totalCards: Int
}

struct WidgetData: Codable {
    let dueCardCount: Int
    let streakDays: Int
    let overdueCount: Int
    let topDecks: [WidgetDeckInfo]
    let mostUrgentDeckID: UUID?
    let updatedAt: Date
    let languageCode: String
}

enum WidgetDataService {
    static let suiteName = "group.geunil.KonitFlash"
    static let dataKey = "widgetData"

    static func writeWidgetData(from modelContext: ModelContext) {
        let decks = fetchDecks(from: modelContext)
        let logs = fetchAllLogs(from: modelContext)

        let now = Date()
        let allCards = decks.flatMap { $0.cards ?? [] }
        let dueCardCount = allCards.filter { $0.dueDate <= now }.count
        let overdueCount = allCards.filter { $0.dueDate < now }.count
        let streakDays = computeStreak(logs: logs)

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
            overdueCount: overdueCount,
            topDecks: topDecks,
            mostUrgentDeckID: mostUrgentDeckID,
            updatedAt: now,
            languageCode: languageCode
        )

        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        do {
            let encoded = try JSONEncoder().encode(data)
            defaults.set(encoded, forKey: dataKey)
        } catch {
            print("[KonitFlash] Failed to encode widget data: \(error)")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Private

    private static func fetchDecks(from modelContext: ModelContext) -> [Deck] {
        let descriptor = FetchDescriptor<Deck>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private static func fetchAllLogs(from modelContext: ModelContext) -> [StudyLog] {
        let descriptor = FetchDescriptor<StudyLog>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private static func computeStreak(logs: [StudyLog]) -> Int {
        guard !logs.isEmpty else { return 0 }

        let calendar = Calendar.current
        let studyDates = Set(logs.map { calendar.startOfDay(for: $0.studiedAt) })

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        if !studyDates.contains(checkDate) {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = previous
            if !studyDates.contains(checkDate) {
                return 0
            }
        }

        while studyDates.contains(checkDate) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previous
        }

        return streak
    }
}

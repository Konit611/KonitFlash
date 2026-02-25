import WidgetKit
import SwiftUI

// MARK: - Codable types (duplicated for widget target independence)

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
    let topDecks: [WidgetDeckInfo]
    let mostUrgentDeckID: UUID?
    let updatedAt: Date
    let languageCode: String
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

// MARK: - Timeline Entry

struct StudyEntry: TimelineEntry {
    let date: Date
    let data: WidgetData?
}

// MARK: - Timeline Provider

struct StudyTimelineProvider: TimelineProvider {
    private static let suiteName = "group.geunil.KonitFlash"
    private static let dataKey = "widgetData"
    private static let rawDataKey = "widgetRawData"

    func placeholder(in context: Context) -> StudyEntry {
        StudyEntry(
            date: Date(),
            data: WidgetData(
                dueCardCount: 12,
                streakDays: 3,
                topDecks: [
                    WidgetDeckInfo(id: UUID(), name: "Japanese N3", colorTag: "pink", dueCards: 5, totalCards: 100),
                    WidgetDeckInfo(id: UUID(), name: "Swift API", colorTag: "green", dueCards: 4, totalCards: 50),
                    WidgetDeckInfo(id: UUID(), name: "History", colorTag: "pink", dueCards: 3, totalCards: 30)
                ],
                mostUrgentDeckID: nil,
                updatedAt: Date(),
                languageCode: "en"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StudyEntry) -> Void) {
        completion(StudyEntry(date: Date(), data: readWidgetData()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StudyEntry>) -> Void) {
        guard let rawData = readRawData() else {
            let entry = StudyEntry(date: Date(), data: readWidgetData())
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            return
        }

        let now = Date()
        let horizon = Calendar.current.date(byAdding: .hour, value: 24, to: now) ?? now

        // Collect unique future due times within the 24-hour window
        var futureDueTimes: Set<Date> = []
        for deck in rawData.decks {
            for dueDate in deck.cardDueDates where dueDate > now && dueDate <= horizon {
                futureDueTimes.insert(dueDate)
            }
        }

        // Build entry time points: now + each future due time, sorted
        var entryDates = [now] + futureDueTimes.sorted()
        // Cap at 24 entries to respect iOS widget memory limits
        if entryDates.count > 24 {
            entryDates = Array(entryDates.prefix(24))
        }

        let entries = entryDates.map { entryDate in
            StudyEntry(date: entryDate, data: computeWidgetData(from: rawData, at: entryDate))
        }

        completion(Timeline(entries: entries, policy: .after(horizon)))
    }

    // MARK: - Private

    private func readWidgetData() -> WidgetData? {
        guard let defaults = UserDefaults(suiteName: Self.suiteName),
              let jsonData = defaults.data(forKey: Self.dataKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetData.self, from: jsonData)
    }

    private func readRawData() -> WidgetRawData? {
        guard let defaults = UserDefaults(suiteName: Self.suiteName),
              let jsonData = defaults.data(forKey: Self.rawDataKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetRawData.self, from: jsonData)
    }

    private func computeWidgetData(from rawData: WidgetRawData, at date: Date) -> WidgetData {
        let deckInfos = rawData.decks.map { snapshot -> WidgetDeckInfo in
            let dueCount = snapshot.cardDueDates.filter { $0 <= date }.count
            return WidgetDeckInfo(
                id: snapshot.id,
                name: snapshot.name,
                colorTag: snapshot.colorTag,
                dueCards: dueCount,
                totalCards: snapshot.totalCards
            )
        }
        .sorted { $0.dueCards > $1.dueCards }

        let totalDue = deckInfos.reduce(0) { $0 + $1.dueCards }
        let topDecks = Array(deckInfos.prefix(3))
        let mostUrgentDeckID = deckInfos.first(where: { $0.dueCards > 0 })?.id

        return WidgetData(
            dueCardCount: totalDue,
            streakDays: rawData.streakDays,
            topDecks: topDecks,
            mostUrgentDeckID: mostUrgentDeckID,
            updatedAt: date,
            languageCode: rawData.languageCode
        )
    }
}

// MARK: - Widget Definition

struct KonitFlashWidget: Widget {
    let kind = "KonitFlashWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyTimelineProvider()) { entry in
            KonitFlashWidgetEntryView(entry: entry)
                .containerBackground(Color.widgetBackground, for: .widget)
        }
        .configurationDisplayName("Today's Study")
        .description("See your due cards and study streak at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    KonitFlashWidget()
} timeline: {
    StudyEntry(
        date: Date(),
        data: WidgetData(
            dueCardCount: 12,
            streakDays: 3,
            topDecks: [],
            mostUrgentDeckID: UUID(),
            updatedAt: Date(),
            languageCode: "en"
        )
    )
    StudyEntry(date: Date(), data: nil)
}

#Preview("Medium", as: .systemMedium) {
    KonitFlashWidget()
} timeline: {
    StudyEntry(
        date: Date(),
        data: WidgetData(
            dueCardCount: 12,
            streakDays: 3,
            topDecks: [
                WidgetDeckInfo(id: UUID(), name: "Japanese N3", colorTag: "pink", dueCards: 5, totalCards: 100),
                WidgetDeckInfo(id: UUID(), name: "Swift API", colorTag: "green", dueCards: 4, totalCards: 50),
                WidgetDeckInfo(id: UUID(), name: "History", colorTag: "pink", dueCards: 3, totalCards: 30)
            ],
            mostUrgentDeckID: UUID(),
            updatedAt: Date(),
            languageCode: "en"
        )
    )
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    KonitFlashWidget()
} timeline: {
    StudyEntry(
        date: Date(),
        data: WidgetData(
            dueCardCount: 12,
            streakDays: 3,
            topDecks: [],
            mostUrgentDeckID: UUID(),
            updatedAt: Date(),
            languageCode: "en"
        )
    )
}

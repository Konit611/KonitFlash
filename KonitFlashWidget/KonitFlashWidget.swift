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

// MARK: - Timeline Entry

struct StudyEntry: TimelineEntry {
    let date: Date
    let data: WidgetData?
}

// MARK: - Timeline Provider

struct StudyTimelineProvider: TimelineProvider {
    private static let suiteName = "group.geunil.KonitFlash"
    private static let dataKey = "widgetData"

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
        let entry = StudyEntry(date: Date(), data: readWidgetData())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func readWidgetData() -> WidgetData? {
        guard let defaults = UserDefaults(suiteName: Self.suiteName),
              let jsonData = defaults.data(forKey: Self.dataKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetData.self, from: jsonData)
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
            overdueCount: 5,
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
            overdueCount: 5,
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
            overdueCount: 5,
            topDecks: [],
            mostUrgentDeckID: UUID(),
            updatedAt: Date(),
            languageCode: "en"
        )
    )
}

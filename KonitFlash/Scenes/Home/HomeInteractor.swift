import Foundation
import SwiftData

struct HomeData {
    let stats: HomeStats
    let weeklyActivities: [DayActivity]
    let decks: [Deck]
    let firstOverdueDeckID: UUID?
}

final class HomeInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchHomeData() -> HomeData {
        let decks = fetchDecks()
        let allLogs = fetchAllLogs()
        let stats = computeStats(decks: decks, allLogs: allLogs)
        let weeklyActivities = computeWeeklyActivity(allLogs: allLogs)
        let firstOverdueDeckID = findFirstOverdueDeckID(decks: decks)
        return HomeData(stats: stats, weeklyActivities: weeklyActivities, decks: decks, firstOverdueDeckID: firstOverdueDeckID)
    }

    func deleteDeck(id: UUID) {
        let descriptor = FetchDescriptor<Deck>(predicate: #Predicate { $0.id == id })
        guard let deck = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(deck)
        do {
            try modelContext.save()
        } catch {
            print("[KonitFlash] Failed to delete deck: \(error)")
        }
    }

    // MARK: - Private

    private func fetchDecks() -> [Deck] {
        let descriptor = FetchDescriptor<Deck>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchAllLogs() -> [StudyLog] {
        let logDescriptor = FetchDescriptor<StudyLog>()
        return (try? modelContext.fetch(logDescriptor)) ?? []
    }

    private func computeStats(decks: [Deck], allLogs: [StudyLog]) -> HomeStats {
        let allCards = decks.flatMap { $0.cards ?? [] }
        let now = Date()
        let overdueCount = allCards.filter { $0.dueDate < now }.count
        let learnedCount = allCards.filter { $0.repetitions > 0 }.count

        let reviewCount = allLogs.count
        let streakDays = computeStreak(logs: allLogs)

        return HomeStats(
            streakDays: streakDays,
            learnedCount: learnedCount,
            reviewCount: reviewCount,
            overdueCount: overdueCount
        )
    }

    private func computeStreak(logs: [StudyLog]) -> Int {
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

    private func findFirstOverdueDeckID(decks: [Deck]) -> UUID? {
        let now = Date()
        return decks.first { deck in
            (deck.cards ?? []).contains { $0.dueDate < now }
        }?.id
    }

    private func computeWeeklyActivity(allLogs: [StudyLog]) -> [DayActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return []
        }

        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.locale
        let dayLabels = (0..<7).map { offset -> String in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else { return "" }
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }

        return (0..<7).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return DayActivity(dayLabel: dayLabels[offset], studiedCards: 0, isToday: false)
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else {
                return DayActivity(dayLabel: dayLabels[offset], studiedCards: 0, isToday: false)
            }
            let logsForDay = allLogs.filter { $0.studiedAt >= date && $0.studiedAt < nextDate }
            let isToday = calendar.isDateInToday(date)
            return DayActivity(
                dayLabel: dayLabels[offset],
                studiedCards: logsForDay.count,
                isToday: isToday
            )
        }
    }
}

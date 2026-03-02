import Foundation
import os
import SwiftData

private let logger = Logger(subsystem: "geunil.KonitFlash", category: "HomeInteractor")

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
        let recentLogs = fetchRecentLogs()
        let totalReviewCount = fetchTotalReviewCount()
        let stats = computeStats(decks: decks, recentLogs: recentLogs, totalReviewCount: totalReviewCount)
        let weeklyActivities = computeWeeklyActivity(allLogs: recentLogs)
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
            logger.error("Failed to delete deck: \(error)")
        }
    }

    // MARK: - Private

    private func fetchDecks() -> [Deck] {
        let descriptor = FetchDescriptor<Deck>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchRecentLogs() -> [StudyLog] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<StudyLog>(
            predicate: #Predicate { $0.studiedAt >= cutoff }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchTotalReviewCount() -> Int {
        let descriptor = FetchDescriptor<StudyLog>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    private func computeStats(decks: [Deck], recentLogs: [StudyLog], totalReviewCount: Int) -> HomeStats {
        let allCards = decks.flatMap { $0.cards ?? [] }
        let now = Date()
        let overdueCount = allCards.filter { $0.dueDate < now }.count
        let learnedCount = allCards.filter { $0.repetitions > 0 }.count

        let streakDays = StudyLog.computeStreak(from: recentLogs)

        return HomeStats(
            streakDays: streakDays,
            learnedCount: learnedCount,
            reviewCount: totalReviewCount,
            overdueCount: overdueCount
        )
    }

    private func findFirstOverdueDeckID(decks: [Deck]) -> UUID? {
        let now = Date()
        return decks.first { deck in
            (deck.cards ?? []).contains { $0.dueDate < now }
        }?.id
    }

    private func computeWeeklyActivity(allLogs: [StudyLog]) -> [DayActivity] {
        let calendar = Calendar.current
        let monday = mondayOfCurrentWeek(calendar: calendar)
        guard let monday else { return [] }

        let dayLabels = weekdayLabels(from: monday, calendar: calendar)

        return (0..<7).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return DayActivity(dayLabel: dayLabels[offset], studiedCards: 0, isToday: false)
            }
            let count = studiedCount(for: date, in: allLogs, calendar: calendar)
            return DayActivity(
                dayLabel: dayLabels[offset],
                studiedCards: count,
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    private func mondayOfCurrentWeek(calendar: Calendar) -> Date? {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: today)
    }

    private func weekdayLabels(from monday: Date, calendar: Calendar) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.locale
        formatter.dateFormat = "EEE"
        return (0..<7).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else { return "" }
            return formatter.string(from: date)
        }
    }

    private func studiedCount(for date: Date, in logs: [StudyLog], calendar: Calendar) -> Int {
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { return 0 }
        return logs.filter { $0.studiedAt >= date && $0.studiedAt < nextDate }.count
    }
}

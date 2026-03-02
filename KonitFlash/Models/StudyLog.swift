import Foundation
import SwiftData

@Model final class StudyLog {
    var id: UUID = UUID()
    var card: Card?
    var grade: Int = 0
    var studiedAt: Date = Date()
    var elapsedSeconds: Double = 0

    init(card: Card? = nil, grade: Int = 0, elapsedSeconds: Double = 0) {
        self.card = card
        self.grade = min(max(0, grade), 3)
        self.elapsedSeconds = elapsedSeconds
    }

    static func computeStreak(from logs: [StudyLog]) -> Int {
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

import Foundation
import SwiftData

@Model final class StudyLog {
    var id: UUID = UUID()
    var card: Card?
    var grade: Int = 0
    var studiedAt: Date = Date()
    var elapsedSeconds: Double = 0

    init(card: Card? = nil, grade: Int = 0, elapsedSeconds: Double = 0) {
        self.id = UUID()
        self.card = card
        self.grade = grade
        self.studiedAt = Date()
        self.elapsedSeconds = elapsedSeconds
    }
}

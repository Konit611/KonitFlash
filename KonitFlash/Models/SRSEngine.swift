import Foundation

struct SRSResult {
    let interval: Double
    let easeFactor: Double
    let repetitions: Int
    let dueDate: Date
    let box: Int
}

enum SRSEngine {
    static let minimumEF: Double = 1.3
    static let maximumEF: Double = 3.0
    static let maximumInterval: Double = 365

    static func compute(
        grade: AnswerGrade,
        currentInterval: Double,
        currentEF: Double,
        currentRepetitions: Int,
        currentBox: Int
    ) -> SRSResult {
        let now = Date()
        var newInterval: Double
        var newEF = currentEF
        var newRepetitions = currentRepetitions
        var newBox = currentBox

        switch grade {
        case .again:
            newEF = max(minimumEF, currentEF - 0.20)
            newInterval = 1.0 / (24.0 * 60.0) // ~1 minute in days
            newRepetitions = 0
            newBox = 1

        case .hard:
            newEF = max(minimumEF, currentEF - 0.15)
            newRepetitions = currentRepetitions + 1

            if currentRepetitions == 0 {
                newInterval = 10.0 / (24.0 * 60.0) // 10 minutes
                newBox = 1
            } else {
                newInterval = max(1, currentInterval * 1.2)
                newBox = min(currentBox + 1, 5)
            }

        case .good:
            newRepetitions = currentRepetitions + 1

            if currentRepetitions == 0 {
                newInterval = 1 // 1 day
                newBox = 2
            } else if currentRepetitions == 1 {
                newInterval = 6 // 6 days
                newBox = 3
            } else {
                newInterval = currentInterval * currentEF
                newBox = min(currentBox + 1, 5)
            }

        case .easy:
            newEF = min(maximumEF, currentEF + 0.15)
            newRepetitions = currentRepetitions + 1

            if currentRepetitions == 0 {
                newInterval = 4 // 4 days
                newBox = 3
            } else {
                newInterval = currentInterval * currentEF * 1.3
                newBox = min(currentBox + 1, 5)
            }
        }

        newInterval = min(newInterval, maximumInterval)

        let dueDate = Calendar.current.date(
            byAdding: .second,
            value: Int(newInterval * 86400),
            to: now
        ) ?? now

        return SRSResult(
            interval: newInterval,
            easeFactor: newEF,
            repetitions: newRepetitions,
            dueDate: dueDate,
            box: newBox
        )
    }

    static func previewIntervals(
        currentInterval: Double,
        currentEF: Double,
        currentRepetitions: Int,
        currentBox: Int,
        bundle: Bundle = .main
    ) -> [AnswerGrade: String] {
        var results: [AnswerGrade: String] = [:]
        for grade in AnswerGrade.allCases {
            let result = compute(
                grade: grade,
                currentInterval: currentInterval,
                currentEF: currentEF,
                currentRepetitions: currentRepetitions,
                currentBox: currentBox
            )
            results[grade] = formatInterval(result.interval, bundle: bundle)
        }
        return results
    }

    static func formatInterval(_ days: Double, bundle: Bundle = .main) -> String {
        let minutes = days * 24 * 60
        if minutes < 1 {
            return String(localized: "<1 min", bundle: bundle)
        } else if minutes < 60 {
            let m = Int(minutes)
            return String(localized: "\(m) min", bundle: bundle)
        } else if days < 1 {
            let h = Int(days * 24)
            return String(localized: "\(h) hr", bundle: bundle)
        } else {
            let d = Int(round(days))
            return String(localized: "\(d) day", bundle: bundle)
        }
    }
}

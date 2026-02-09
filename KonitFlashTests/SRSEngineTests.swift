import Testing
import Foundation
@testable import KonitFlash

struct SRSEngineTests {

    // MARK: - Again Grade

    @Test func againResetsRepetitions() {
        let result = SRSEngine.compute(
            grade: .again,
            currentInterval: 10,
            currentEF: 2.5,
            currentRepetitions: 3,
            currentBox: 4
        )
        #expect(result.repetitions == 0)
        #expect(result.box == 1)
    }

    @Test func againDecreasesEF() {
        let result = SRSEngine.compute(
            grade: .again,
            currentInterval: 5,
            currentEF: 2.5,
            currentRepetitions: 2,
            currentBox: 3
        )
        #expect(abs(result.easeFactor - 2.3) < 0.01)
    }

    @Test func againSetsVeryShortInterval() {
        let result = SRSEngine.compute(
            grade: .again,
            currentInterval: 30,
            currentEF: 2.5,
            currentRepetitions: 5,
            currentBox: 5
        )
        #expect(result.interval < 0.01) // Less than ~14 minutes in days
    }

    @Test func againEFNeverBelowMinimum() {
        let result = SRSEngine.compute(
            grade: .again,
            currentInterval: 1,
            currentEF: 1.3,
            currentRepetitions: 1,
            currentBox: 2
        )
        #expect(result.easeFactor >= SRSEngine.minimumEF)
    }

    // MARK: - Hard Grade

    @Test func hardFirstStudy() {
        let result = SRSEngine.compute(
            grade: .hard,
            currentInterval: 0,
            currentEF: 2.5,
            currentRepetitions: 0,
            currentBox: 1
        )
        #expect(result.repetitions == 1)
        #expect(result.box == 1)
        // 10 min = 10/(24*60) ≈ 0.00694 days
        #expect(result.interval < 0.01)
    }

    @Test func hardIncreasesIntervalBy1_2() {
        let result = SRSEngine.compute(
            grade: .hard,
            currentInterval: 10,
            currentEF: 2.5,
            currentRepetitions: 3,
            currentBox: 3
        )
        #expect(abs(result.interval - 12) < 0.01) // 10 * 1.2 = 12
        #expect(result.repetitions == 4)
    }

    @Test func hardDecreasesEF() {
        let result = SRSEngine.compute(
            grade: .hard,
            currentInterval: 5,
            currentEF: 2.5,
            currentRepetitions: 2,
            currentBox: 2
        )
        #expect(abs(result.easeFactor - 2.35) < 0.01)
    }

    // MARK: - Good Grade

    @Test func goodFirstStudyGives1Day() {
        let result = SRSEngine.compute(
            grade: .good,
            currentInterval: 0,
            currentEF: 2.5,
            currentRepetitions: 0,
            currentBox: 1
        )
        #expect(abs(result.interval - 1) < 0.01)
        #expect(result.repetitions == 1)
        #expect(result.box == 2)
    }

    @Test func goodSecondStudyGives6Days() {
        let result = SRSEngine.compute(
            grade: .good,
            currentInterval: 1,
            currentEF: 2.5,
            currentRepetitions: 1,
            currentBox: 2
        )
        #expect(abs(result.interval - 6) < 0.01)
        #expect(result.repetitions == 2)
        #expect(result.box == 3)
    }

    @Test func goodMultipliesByEF() {
        let result = SRSEngine.compute(
            grade: .good,
            currentInterval: 6,
            currentEF: 2.5,
            currentRepetitions: 2,
            currentBox: 3
        )
        #expect(abs(result.interval - 15) < 0.01) // 6 * 2.5 = 15
        #expect(result.repetitions == 3)
    }

    @Test func goodKeepsEFUnchanged() {
        let result = SRSEngine.compute(
            grade: .good,
            currentInterval: 10,
            currentEF: 2.5,
            currentRepetitions: 3,
            currentBox: 4
        )
        #expect(abs(result.easeFactor - 2.5) < 0.01)
    }

    // MARK: - Easy Grade

    @Test func easyFirstStudyGives4Days() {
        let result = SRSEngine.compute(
            grade: .easy,
            currentInterval: 0,
            currentEF: 2.5,
            currentRepetitions: 0,
            currentBox: 1
        )
        #expect(abs(result.interval - 4) < 0.01)
        #expect(result.repetitions == 1)
        #expect(result.box == 3)
    }

    @Test func easyMultipliesByEFTimes1_3() {
        let result = SRSEngine.compute(
            grade: .easy,
            currentInterval: 10,
            currentEF: 2.5,
            currentRepetitions: 3,
            currentBox: 3
        )
        let expected = 10 * 2.5 * 1.3 // 32.5
        #expect(abs(result.interval - expected) < 0.01)
    }

    @Test func easyIncreasesEF() {
        let result = SRSEngine.compute(
            grade: .easy,
            currentInterval: 10,
            currentEF: 2.5,
            currentRepetitions: 3,
            currentBox: 3
        )
        #expect(abs(result.easeFactor - 2.65) < 0.01)
    }

    // MARK: - Edge Cases

    @Test func intervalNeverExceeds365() {
        let result = SRSEngine.compute(
            grade: .easy,
            currentInterval: 300,
            currentEF: 3.0,
            currentRepetitions: 10,
            currentBox: 5
        )
        #expect(result.interval <= SRSEngine.maximumInterval)
    }

    @Test func efNeverBelowMinimum() {
        var ef = 2.5
        for _ in 0..<20 {
            let result = SRSEngine.compute(
                grade: .again,
                currentInterval: 1,
                currentEF: ef,
                currentRepetitions: 1,
                currentBox: 1
            )
            ef = result.easeFactor
        }
        #expect(ef >= SRSEngine.minimumEF)
    }

    @Test func boxNeverExceeds5() {
        let result = SRSEngine.compute(
            grade: .easy,
            currentInterval: 100,
            currentEF: 2.5,
            currentRepetitions: 10,
            currentBox: 5
        )
        #expect(result.box <= 5)
    }

    @Test func dueDateIsInFuture() {
        let now = Date()
        let result = SRSEngine.compute(
            grade: .good,
            currentInterval: 1,
            currentEF: 2.5,
            currentRepetitions: 1,
            currentBox: 2
        )
        #expect(result.dueDate > now)
    }

    // MARK: - Format Interval

    @Test func formatIntervalLessThanMinute() {
        #expect(SRSEngine.formatInterval(0.0001) == "<1 min")
    }

    @Test func formatIntervalMinutes() {
        let tenMinInDays = 10.0 / (24.0 * 60.0)
        #expect(SRSEngine.formatInterval(tenMinInDays) == "10 min")
    }

    @Test func formatInterval1Day() {
        #expect(SRSEngine.formatInterval(1.0) == "1 day")
    }

    @Test func formatIntervalMultipleDays() {
        #expect(SRSEngine.formatInterval(7.0) == "7 days")
    }

    // MARK: - Preview Intervals

    @Test func previewIntervalsReturnsAllGrades() {
        let result = SRSEngine.previewIntervals(
            currentInterval: 5,
            currentEF: 2.5,
            currentRepetitions: 2,
            currentBox: 3
        )
        #expect(result.count == 4)
        #expect(result[.again] != nil)
        #expect(result[.hard] != nil)
        #expect(result[.good] != nil)
        #expect(result[.easy] != nil)
    }
}

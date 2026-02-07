import SwiftUI

enum AnswerGrade: CaseIterable {
    case again, hard, good, easy

    var label: String {
        switch self {
        case .again: "Again"
        case .hard: "Hard"
        case .good: "Good"
        case .easy: "Easy"
        }
    }

    var color: Color {
        switch self {
        case .again: .overdueText
        case .hard: .streakPink
        case .good: .learnedGreen
        case .easy: .weeklyMint
        }
    }

    var textColor: Color {
        switch self {
        case .again: .white
        case .hard, .good, .easy: .black
        }
    }
}

struct AnswerButtonRow: View {
    let intervals: [AnswerGrade: String]
    let onSelect: (AnswerGrade) -> Void
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        HStack(spacing: isRegular ? 12 : 8) {
            ForEach(AnswerGrade.allCases, id: \.self) { grade in
                Button {
                    onSelect(grade)
                } label: {
                    VStack(spacing: 4) {
                        Text(grade.label)
                            .font(.system(size: isRegular ? 16 : 14, weight: .bold))
                        Text(intervals[grade] ?? "")
                            .font(.system(size: isRegular ? 13 : 11))
                    }
                    .foregroundStyle(grade.textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isRegular ? 14 : 10)
                    .background(grade.color, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

#Preview("iPhone") {
    AnswerButtonRow(
        intervals: [.again: "<1 min", .hard: "1 min", .good: "2 days", .easy: "8 days"],
        onSelect: { _ in }
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    AnswerButtonRow(
        intervals: [.again: "<1 min", .hard: "1 min", .good: "2 days", .easy: "8 days"],
        onSelect: { _ in }
    )
    .padding(40)
    .frame(width: 700)
    .background(Color.appBackground)
}

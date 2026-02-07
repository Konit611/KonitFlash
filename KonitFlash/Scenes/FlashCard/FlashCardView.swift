import SwiftUI

struct FlashCardView: View {
    @StateObject private var presenter: FlashCardPresenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    init(deckID: UUID) {
        _presenter = StateObject(wrappedValue: FlashCardPresenter(deckID: deckID))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, isRegular ? 40 : 15)
                .padding(.top, isRegular ? 20 : 10)
                .padding(.bottom, isRegular ? 14 : 10)

            switch presenter.viewState.phase {
            case .studying:
                studyingContent
            case .result:
                resultContent
            }
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        AppHeaderView(
            title: presenter.viewState.deckName,
            onDismiss: { dismiss() }
        )
    }

    // MARK: - Studying

    private var studyingContent: some View {
        VStack(spacing: isRegular ? 24 : 16) {
            ProgressHeaderView(
                currentIndex: presenter.viewState.currentIndex,
                totalCount: presenter.viewState.totalCount
            )

            Spacer()

            FlashCardContent(
                frontText: presenter.viewState.currentFront,
                backText: presenter.viewState.currentBack,
                isFlipped: presenter.viewState.isFlipped,
                onTap: { presenter.flipCard() }
            )

            Spacer()

            AnswerButtonRow(
                intervals: presenter.viewState.intervals,
                onSelect: { grade in
                    presenter.answerCard(grade: grade)
                }
            )
            .opacity(presenter.viewState.isFlipped ? 1 : 0)
            .allowsHitTesting(presenter.viewState.isFlipped)
            .animation(.easeInOut(duration: 0.3), value: presenter.viewState.isFlipped)
        }
        .padding(.horizontal, isRegular ? 40 : 15)
        .padding(.bottom, isRegular ? 24 : 16)
    }

    // MARK: - Result

    private var resultContent: some View {
        ScrollView {
            VStack(spacing: isRegular ? 24 : 16) {
                StudyResultCard(
                    accuracyPercent: presenter.viewState.accuracyPercent,
                    totalCards: presenter.viewState.totalCards,
                    elapsedTime: presenter.viewState.elapsedTime,
                    goodEasyCount: presenter.viewState.goodEasyCount,
                    againHardCount: presenter.viewState.againHardCount,
                    message: presenter.viewState.resultMessage
                )

                HStack(spacing: isRegular ? 16 : 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Back to Deck")
                            .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isRegular ? 16 : 12)
                            .background(.black, in: RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        presenter.restartSession()
                    } label: {
                        Text("Study Again")
                            .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isRegular ? 16 : 12)
                            .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
    }
}

#Preview("iPhone") {
    NavigationStack {
        FlashCardView(deckID: UUID())
    }
}

#Preview("Mac") {
    NavigationStack {
        FlashCardView(deckID: UUID())
    }
    .frame(width: 1440, height: 900)
}

import SwiftUI
import SwiftData

struct FlashCardView: View {
    @StateObject private var presenter = FlashCardPresenter()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext

    private let deckID: UUID
    private var isRegular: Bool { sizeClass == .regular }

    init(deckID: UUID) {
        self.deckID = deckID
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
            case .waiting:
                waitingContent
            case .result:
                resultContent
            case .empty:
                emptyContent
            }
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure(modelContext: modelContext, deckID: deckID) }
        .onDisappear { WidgetDataService.writeWidgetData(from: modelContext) }
        #if os(macOS)
        .onKeyPress(.space) {
            if presenter.viewState.phase == .studying && !presenter.viewState.isFlipped {
                presenter.flipCard()
                return .handled
            }
            return .ignored
        }
        .onKeyPress(characters: .init(["1"])) {
            if presenter.viewState.phase == .studying && presenter.viewState.isFlipped {
                presenter.answerCard(grade: .again)
                return .handled
            }
            return .ignored
        }
        .onKeyPress(characters: .init(["2"])) {
            if presenter.viewState.phase == .studying && presenter.viewState.isFlipped {
                presenter.answerCard(grade: .hard)
                return .handled
            }
            return .ignored
        }
        .onKeyPress(characters: .init(["3"])) {
            if presenter.viewState.phase == .studying && presenter.viewState.isFlipped {
                presenter.answerCard(grade: .good)
                return .handled
            }
            return .ignored
        }
        .onKeyPress(characters: .init(["4"])) {
            if presenter.viewState.phase == .studying && presenter.viewState.isFlipped {
                presenter.answerCard(grade: .easy)
                return .handled
            }
            return .ignored
        }
        #endif
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

    // MARK: - Waiting

    private var waitingContent: some View {
        VStack(spacing: isRegular ? 24 : 16) {
            ProgressHeaderView(
                currentIndex: presenter.viewState.currentIndex,
                totalCount: presenter.viewState.totalCount
            )

            Spacer()

            VStack(spacing: isRegular ? 20 : 14) {
                Image(systemName: "clock.fill")
                    .font(.system(size: isRegular ? 48 : 36))
                    .foregroundStyle(Color.weeklyMint)

                Text("Next card in", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 20 : 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))

                Text(presenter.viewState.waitingCountdown)
                    .font(.system(size: isRegular ? 56 : 44, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.white)

                Text(presenter.viewState.waitingMessage)
                    .font(.system(size: isRegular ? 16 : 13))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                presenter.skipWaiting()
            } label: {
                Text("End Session", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isRegular ? 16 : 12)
                    .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
            }
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
                        Text("Back to Deck", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isRegular ? 16 : 12)
                            .background(.black, in: RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        presenter.restartSession()
                    } label: {
                        Text("Study Again", bundle: LanguageManager.shared.bundle)
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

    // MARK: - Empty

    private var emptyContent: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "checkmark.circle",
                title: String(localized: "All Caught Up!", bundle: LanguageManager.shared.bundle),
                message: String(localized: "You've completed all reviews for today", bundle: LanguageManager.shared.bundle)
            )
            Spacer()
        }
        .padding(.horizontal, isRegular ? 40 : 15)
    }
}

#Preview("iPhone") {
    NavigationStack {
        FlashCardView(deckID: UUID())
    }
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

#Preview("Mac") {
    NavigationStack {
        FlashCardView(deckID: UUID())
    }
    .frame(width: 1440, height: 900)
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

import SwiftUI

struct DeckDetailView: View {
    @StateObject private var presenter: DeckDetailPresenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    init(deckID: UUID) {
        _presenter = StateObject(wrappedValue: DeckDetailPresenter(deckID: deckID))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 14 : 10) {
                header
                    .padding(.bottom, isRegular ? 0 : 10)

                if isRegular {
                    HStack(spacing: 8) {
                        DeckInfoCard(
                            deckName: presenter.viewState.deckName,
                            description: presenter.viewState.deckDescription,
                            dueTodayCount: presenter.viewState.dueTodayCount,
                            totalCards: presenter.viewState.totalCards,
                            progress: presenter.viewState.progress,
                            progressPercent: presenter.viewState.progressPercent,
                            progressColor: presenter.viewState.progressColor
                        )

                        DeckStatsSection(
                            newCount: presenter.viewState.newCount,
                            learningCount: presenter.viewState.learningCount,
                            reviewedCount: presenter.viewState.reviewedCount
                        )
                    }
                    .frame(height: 241)
                } else {
                    DeckInfoCard(
                        deckName: presenter.viewState.deckName,
                        description: presenter.viewState.deckDescription,
                        dueTodayCount: presenter.viewState.dueTodayCount,
                        totalCards: presenter.viewState.totalCards,
                        progress: presenter.viewState.progress,
                        progressPercent: presenter.viewState.progressPercent,
                        progressColor: presenter.viewState.progressColor
                    )

                    DeckStatsSection(
                        newCount: presenter.viewState.newCount,
                        learningCount: presenter.viewState.learningCount,
                        reviewedCount: presenter.viewState.reviewedCount
                    )
                }

                cardsSection
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            if isRegular {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.appBackground)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle().stroke(Color.learnedGreen.opacity(0.3), lineWidth: 1)
                            )
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.learnedGreen)
                    }
                    .onTapGesture { dismiss() }
                    Text("KONIT Flash")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
            } else {
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }

            Spacer()

            Button {
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: isRegular ? 22 : 18))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }

    // MARK: - Cards Section

    private var cardsSection: some View {
        VStack(spacing: isRegular ? 14 : 10) {
            HStack {
                Text(isRegular ? "My Flash Decks" : "Cards in Deck")
                    .font(.system(size: isRegular ? 32 : 20, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: isRegular ? 16 : 14, weight: .medium))
                        Text("Add Card")
                            .font(.system(size: isRegular ? 20 : 16, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 24 : 16)
                    .padding(.vertical, isRegular ? 12 : 8)
                    .background(.white, in: RoundedRectangle(cornerRadius: isRegular ? 12 : 18))
                }
            }
            .padding(.top, 6)

            ForEach(presenter.viewState.cards) { card in
                CardRowView(card: card)
            }
        }
    }
}

#Preview("iPhone") {
    NavigationStack {
        DeckDetailView(deckID: UUID())
    }
}

#Preview("Mac") {
    NavigationStack {
        DeckDetailView(deckID: UUID())
    }
    .frame(width: 1440, height: 900)
}

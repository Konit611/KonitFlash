import SwiftData
import SwiftUI

struct OverdueListView: View {
    @StateObject private var presenter = OverdueListPresenter()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.modelContext) private var modelContext

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(spacing: isRegular ? 14 : 10) {
                AppHeaderView(
                    title: String(localized: "Overdue Cards", bundle: LanguageManager.shared.bundle),
                    onDismiss: { dismiss() }
                )
                .padding(.bottom, isRegular ? 0 : 10)

                if presenter.viewState.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: String(localized: "No Overdue Cards", bundle: LanguageManager.shared.bundle),
                        message: String(localized: "All overdue cards have been cleared", bundle: LanguageManager.shared.bundle)
                    )
                } else {
                    ForEach(presenter.viewState.deckGroups) { group in
                        deckGroupSection(group)
                    }
                }
            }
            .padding(.horizontal, isRegular ? 40 : 15)
            .padding(.top, isRegular ? 20 : 10)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear { presenter.configure(modelContext: modelContext) }
    }

    private func deckGroupSection(_ group: OverdueDeckGroup) -> some View {
        VStack(spacing: isRegular ? 10 : 8) {
            HStack {
                Text(group.deckName)
                    .font(.system(size: isRegular ? 22 : 17, weight: .semibold))
                    .foregroundStyle(.white)

                Text("\(group.cards.count)")
                    .font(.system(size: isRegular ? 14 : 12, weight: .bold))
                    .foregroundStyle(Color.overdueText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.overdueBg, in: RoundedRectangle(cornerRadius: 6))

                Spacer()

                NavigationLink(value: NavigationRoute.flashCard(deckID: group.id)) {
                    HStack(spacing: 4) {
                        Text("Start", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: isRegular ? 16 : 14, weight: .semibold))
                            .lineLimit(1)
                        Image(systemName: "arrow.right")
                            .font(.system(size: isRegular ? 12 : 10, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 16 : 12)
                    .padding(.vertical, isRegular ? 8 : 6)
                    .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 10))
                }
                .fixedSize()
            }

            ForEach(group.cards) { card in
                overdueCardRow(card)
            }
        }
    }

    private func overdueCardRow(_ card: OverdueCardRowData) -> some View {
        HStack(spacing: isRegular ? 20 : 15) {
            Text("\(card.box)")
                .font(.system(size: isRegular ? 28 : 24, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                .background(Color.overdueBg, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: isRegular ? 6 : 4) {
                SmartText(card.front)
                    .font(.system(size: isRegular ? 30 : 20, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(card.dueDateText)
                    .font(.system(size: isRegular ? 16 : 12))
                    .foregroundStyle(Color(hex: 0x555555))
            }

            Spacer()
        }
        .padding(.horizontal, isRegular ? 20 : 15)
        .padding(.vertical, isRegular ? 25 : 18)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview("iPhone") {
    NavigationStack {
        OverdueListView()
    }
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

#Preview("Mac") {
    NavigationStack {
        OverdueListView()
    }
    .frame(width: 1440, height: 900)
    .modelContainer(for: [Deck.self, Card.self, StudyLog.self], inMemory: true)
}

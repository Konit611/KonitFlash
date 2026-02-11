import SwiftUI
import SwiftData

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
                    ForEach(presenter.viewState.cards) { card in
                        overdueCardRow(card)
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

    private func overdueCardRow(_ card: OverdueCardRowData) -> some View {
        HStack(spacing: isRegular ? 20 : 15) {
            Text("\(card.box)")
                .font(.system(size: isRegular ? 28 : 24, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                .background(Color.overdueBg, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: isRegular ? 6 : 4) {
                Text(card.front)
                    .font(.system(size: isRegular ? 30 : 20, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(card.deckName)
                        .font(.system(size: isRegular ? 16 : 12, weight: .medium))
                        .foregroundStyle(Color.overdueText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.overdueBg, in: RoundedRectangle(cornerRadius: 6))

                    Text(card.dueDateText)
                        .font(.system(size: isRegular ? 16 : 12))
                        .foregroundStyle(Color(hex: 0x555555))
                }
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

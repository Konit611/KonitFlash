import SwiftUI

struct DeckCardView: View {
    let deck: DeckViewData
    var onStartTap: (() -> Void)?
    var onEditTap: (() -> Void)?
    var onDeleteTap: (() -> Void)?

    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(deck.name)
                    .font(.system(size: isRegular ? 30 : 24, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
                Menu {
                    Button { onEditTap?() } label: {
                        Label(String(localized: "Edit Deck", bundle: LanguageManager.shared.bundle), systemImage: "pencil")
                    }
                    Button(role: .destructive) { onDeleteTap?() } label: {
                        Label(String(localized: "Delete Deck", bundle: LanguageManager.shared.bundle), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: isRegular ? 20 : 16, weight: .bold))
                        .foregroundStyle(.black.opacity(0.4))
                        .padding(4)
                }
            }
            .padding(.bottom, isRegular ? 8 : 6)

            Text(deck.description)
                .font(.system(size: isRegular ? 18 : 15))
                .foregroundStyle(Color(hex: 0x555555))
                .lineLimit(1)
                .padding(.bottom, isRegular ? 18 : 14)

            HStack(spacing: isRegular ? 14 : 10) {
                VStack(spacing: 2) {
                    Text(deck.totalCards)
                        .font(.system(size: isRegular ? 20 : 16, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Total", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 14 : 12))
                        .foregroundStyle(Color(hex: 0x555555))
                }

                VStack(spacing: 4) {
                    HStack {
                        Spacer()
                        Text(deck.progressPercent)
                            .font(.system(size: isRegular ? 14 : 12, weight: .semibold))
                            .foregroundStyle(Color(hex: 0x9095A1))
                    }
                    GeometryReader { geo in
                        Capsule()
                            .fill(.black)
                            .frame(height: isRegular ? 9 : 7)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(deck.progressColor)
                                    .frame(width: geo.size.width * min(max(0, deck.progress), 1), height: isRegular ? 7 : 5)
                            }
                            .clipShape(Capsule())
                    }
                    .frame(height: isRegular ? 9 : 7)
                }
            }
            .padding(.bottom, isRegular ? 20 : 16)

            HStack(spacing: 0) {
                HStack(spacing: isRegular ? 4 : 3) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: isRegular ? 14 : 12))
                        .foregroundStyle(.white)
                    Text("\(deck.dueCards)")
                        .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text("cards", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 13 : 11))
                        .foregroundStyle(Color(hex: 0xC7C7C7))
                }

                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: isRegular ? 28 : 24)
                    .padding(.horizontal, isRegular ? 14 : 10)

                HStack(spacing: isRegular ? 4 : 3) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: isRegular ? 14 : 12))
                        .foregroundStyle(.white)
                    Text("\(deck.estimatedMinutes)")
                        .font(.system(size: isRegular ? 18 : 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text("min", bundle: LanguageManager.shared.bundle)
                        .font(.system(size: isRegular ? 13 : 11))
                        .foregroundStyle(Color(hex: 0xC7C7C7))
                }

                Spacer(minLength: 8)

                Button {
                    onStartTap?()
                } label: {
                    HStack(spacing: 4) {
                        Text("Start", bundle: LanguageManager.shared.bundle)
                            .font(.system(size: isRegular ? 18 : 15, weight: .semibold))
                            .lineLimit(1)
                        Image(systemName: "arrow.right")
                            .font(.system(size: isRegular ? 13 : 11, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, isRegular ? 18 : 14)
                    .padding(.vertical, isRegular ? 8 : 6)
                    .background(.white, in: RoundedRectangle(cornerRadius: isRegular ? 14 : 12))
                }
                .fixedSize()
            }
            .padding(.horizontal, isRegular ? 16 : 12)
            .padding(.vertical, isRegular ? 12 : 10)
            .background(.black, in: RoundedRectangle(cornerRadius: isRegular ? 22 : 20))
        }
        .padding(isRegular ? 24 : 20)
        .background(.white, in: RoundedRectangle(cornerRadius: isRegular ? 20 : 18))
    }
}

#Preview {
    VStack(spacing: 10) {
        DeckCardView(deck: DeckViewData(
            id: UUID(),
            name: "English Vocabulary",
            description: "Essential Words for daily conservation",
            progress: 0.6,
            progressPercent: "60%",
            totalCards: "126",
            dueCards: 17,
            estimatedMinutes: 5,
            progressColor: Color.streakPink
        ))
        DeckCardView(deck: DeckViewData(
            id: UUID(),
            name: "English Vocabulary",
            description: "Essential Words for daily conservation",
            progress: 0.6,
            progressPercent: "60%",
            totalCards: "126",
            dueCards: 17,
            estimatedMinutes: 5,
            progressColor: Color.learnedGreen
        ))
    }
    .padding()
    .background(Color.appBackground)
}

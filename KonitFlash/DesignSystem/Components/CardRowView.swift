import SwiftUI

struct CardRowView: View {
    let card: CardRowData
    var onEditTap: (() -> Void)?
    var onDeleteTap: (() -> Void)?
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        HStack(spacing: isRegular ? 20 : 15) {
            Text("\(card.box)")
                .font(.system(size: isRegular ? 28 : 24, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: isRegular ? 50 : 40, height: isRegular ? 50 : 40)
                .background(Color.learnedGreen, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: isRegular ? 6 : 4) {
                Text(card.name)
                    .font(.system(size: isRegular ? 30 : 20, weight: .bold))
                    .foregroundStyle(.black)
                Text(card.dueDateText)
                    .font(.system(size: isRegular ? 16 : 12))
                    .foregroundStyle(Color(hex: 0x555555))
            }

            Spacer()

            Menu {
                Button { onEditTap?() } label: {
                    Label(String(localized: "Edit Card", bundle: LanguageManager.shared.bundle), systemImage: "pencil")
                }
                Button(role: .destructive) { onDeleteTap?() } label: {
                    Label(String(localized: "Delete Card", bundle: LanguageManager.shared.bundle), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: isRegular ? 20 : 16, weight: .bold))
                    .foregroundStyle(.black.opacity(0.4))
                    .frame(width: isRegular ? 40 : nil, height: isRegular ? 40 : nil)
                    .padding(isRegular ? 0 : 4)
            }
        }
        .padding(.horizontal, isRegular ? 20 : 15)
        .padding(.vertical, isRegular ? 25 : 18)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview("iPhone") {
    VStack(spacing: 10) {
        CardRowView(card: CardRowData(
            id: UUID(),
            name: "English",
            dueDateText: "Due: 01/28/2026",
            box: 5,
            isNew: false,
            isDue: false
        ))
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    VStack(spacing: 10) {
        CardRowView(card: CardRowData(
            id: UUID(),
            name: "English",
            dueDateText: "Due: 01/28/2026",
            box: 5,
            isNew: false,
            isDue: false
        ))
    }
    .padding(64)
    .frame(width: 1440)
    .background(Color.appBackground)
}

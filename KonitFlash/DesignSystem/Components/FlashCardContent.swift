import SwiftUI

struct FlashCardContent: View {
    let frontText: String
    let backText: String
    let isFlipped: Bool
    var onTap: () -> Void
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        ZStack {
            // Front
            cardFace(text: frontText, isFront: true)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Back
            cardFace(text: backText, isFront: false)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .animation(.easeInOut(duration: 0.4), value: isFlipped)
        .onTapGesture {
            onTap()
        }
    }

    private func cardFace(text: String, isFront: Bool) -> some View {
        VStack(spacing: isRegular ? 16 : 12) {
            Spacer()
            Text(text)
                .font(.system(size: isFront ? (isRegular ? 32 : 24) : (isRegular ? 28 : 20), weight: isFront ? .bold : .medium))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, isRegular ? 40 : 24)
            if !isFlipped && isFront {
                Text("Tap to flip", bundle: LanguageManager.shared.bundle)
                    .font(.system(size: isRegular ? 16 : 13))
                    .foregroundStyle(Color(hex: 0x9095A1))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: isRegular ? 360 : 260)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview("iPhone") {
    FlashCardContent(
        frontText: "Abandon",
        backText: "포기하다, 버리다",
        isFlipped: false,
        onTap: {}
    )
    .padding()
    .background(Color.appBackground)
}

#Preview("Mac") {
    FlashCardContent(
        frontText: "Abandon",
        backText: "포기하다, 버리다",
        isFlipped: true,
        onTap: {}
    )
    .padding(40)
    .frame(width: 700)
    .background(Color.appBackground)
}

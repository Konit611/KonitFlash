import SwiftUI
import WidgetKit

// MARK: - Entry View (Router)

struct KonitFlashWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: StudyEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryRectangular:
            LockScreenWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Deep Link Helper

private let fallbackURL = URL(string: "konitflash://home")!

private func studyDeepLink(for data: WidgetData?) -> URL {
    guard let deckID = data?.mostUrgentDeckID,
          let url = URL(string: "konitflash://study/\(deckID.uuidString)") else {
        return fallbackURL
    }
    return url
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: StudyEntry

    private var lang: String { entry.data?.languageCode ?? "en" }

    var body: some View {
        if let data = entry.data {
            Link(destination: studyDeepLink(for: data)) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.widgetLearnedGreen)

                        Spacer()

                        if data.streakDays > 0 {
                            HStack(spacing: 2) {
                                Text("🔥")
                                    .font(.system(size: 11))
                                Text("\(data.streakDays)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.widgetStreakPink)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.1), in: Capsule())
                        }
                    }

                    Spacer()

                    if data.dueCardCount > 0 {
                        Text("\(data.dueCardCount)")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.6)

                        Text(WidgetStrings.cardsDue(lang: lang))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    } else {
                        Text(WidgetStrings.allCaughtUp(lang: lang))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.widgetLearnedGreen)
                    }
                }
            }
        } else {
            emptyState
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.widgetLearnedGreen)
            Text(WidgetStrings.noDecksYet(lang: lang))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: StudyEntry

    private var lang: String { entry.data?.languageCode ?? "en" }

    var body: some View {
        if let data = entry.data {
            Link(destination: studyDeepLink(for: data)) {
                HStack(spacing: 16) {
                    leftSection(data: data)
                    rightSection(data: data)
                }
            }
        } else {
            emptyState
        }
    }

    private func leftSection(data: WidgetData) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.widgetLearnedGreen)
                Text(WidgetStrings.todaysStudy(lang: lang))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            if data.dueCardCount > 0 {
                Text("\(data.dueCardCount)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)

                Text(WidgetStrings.cardsDue(lang: lang))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            } else {
                Text(WidgetStrings.allCaughtUp(lang: lang))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.widgetLearnedGreen)
            }

            if data.streakDays > 0 {
                HStack(spacing: 3) {
                    Text("🔥")
                        .font(.system(size: 11))
                    Text(WidgetStrings.streak(count: data.streakDays, lang: lang))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.widgetStreakPink)
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func rightSection(data: WidgetData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if data.topDecks.isEmpty {
                Spacer()
                Text(WidgetStrings.noDecksYet(lang: lang))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
            } else {
                ForEach(data.topDecks, id: \.id) { deck in
                    deckRow(deck)
                }
                if data.topDecks.count < 3 {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func deckRow(_ deck: WidgetDeckInfo) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.widgetColorTag(deck.colorTag))
                .frame(width: 8, height: 8)
            Text(deck.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            if deck.dueCards > 0 {
                Text("\(deck.dueCards)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.15), in: Capsule())
            }
        }
    }

    private var emptyState: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.widgetLearnedGreen)
            Text(WidgetStrings.noDecksYet(lang: lang))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - Lock Screen Widget (accessoryRectangular)

struct LockScreenWidgetView: View {
    let entry: StudyEntry

    private var lang: String { entry.data?.languageCode ?? "en" }

    var body: some View {
        if let data = entry.data {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("KONIT")
                        .font(.system(size: 10, weight: .bold))
                }

                if data.dueCardCount > 0 {
                    HStack(spacing: 4) {
                        if data.streakDays > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("\(data.streakDays)")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            Text("·")
                                .font(.system(size: 13))
                        }
                        HStack(spacing: 2) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text("\(data.dueCardCount)\(WidgetStrings.dueLabel(lang: lang))")
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                } else {
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(WidgetStrings.allCaughtUp(lang: lang))
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
            .widgetURL(studyDeepLink(for: data))
        } else {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("KONIT")
                        .font(.system(size: 10, weight: .bold))
                }
                Text(WidgetStrings.noDecksYet(lang: lang))
                    .font(.system(size: 13, weight: .medium))
            }
        }
    }
}

import Foundation

enum WidgetStrings {
    static func cardsDue(lang: String) -> String {
        switch resolvedLang(lang) {
        case "ko": return "장 복습 예정"
        case "ja": return "枚 復習予定"
        case "zh-Hans": return "张待复习"
        default: return "cards due"
        }
    }

    static func streak(count: Int, lang: String) -> String {
        switch resolvedLang(lang) {
        case "ko": return "\(count)일 연속"
        case "ja": return "\(count)日連続"
        case "zh-Hans": return "\(count)天连续"
        default: return "\(count) day streak"
        }
    }

    static func noDecksYet(lang: String) -> String {
        switch resolvedLang(lang) {
        case "ko": return "덱이 없습니다"
        case "ja": return "デッキがありません"
        case "zh-Hans": return "暂无卡组"
        default: return "No decks yet"
        }
    }

    static func allCaughtUp(lang: String) -> String {
        switch resolvedLang(lang) {
        case "ko": return "모두 완료!"
        case "ja": return "全て完了！"
        case "zh-Hans": return "全部完成！"
        default: return "All caught up!"
        }
    }

    static func dueLabel(lang: String) -> String {
        switch resolvedLang(lang) {
        case "ko": return "장"
        case "ja": return "枚"
        case "zh-Hans": return "张"
        default: return " due"
        }
    }

    static func todaysStudy(lang: String) -> String {
        switch resolvedLang(lang) {
        case "ko": return "오늘의 학습"
        case "ja": return "今日の学習"
        case "zh-Hans": return "今日学习"
        default: return "Today's Study"
        }
    }

    private static func resolvedLang(_ lang: String) -> String {
        if lang == "system" {
            let preferred = Locale.preferredLanguages.first ?? "en"
            if preferred.hasPrefix("ko") { return "ko" }
            if preferred.hasPrefix("ja") { return "ja" }
            if preferred.hasPrefix("zh") { return "zh-Hans" }
            return "en"
        }
        return lang
    }
}

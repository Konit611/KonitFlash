import Testing
import Foundation
@testable import KonitFlash

struct CSVParserTests {

    // MARK: - Basic Parsing

    @Test func parsesSimpleCSV() {
        let csv = "hello,world\nfoo,bar"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 2)
        #expect(result.cards[0].front == "hello")
        #expect(result.cards[0].back == "world")
        #expect(result.cards[1].front == "foo")
        #expect(result.cards[1].back == "bar")
    }

    @Test func parsesTSV() {
        let tsv = "hello\tworld\nfoo\tbar"
        let result = CSVParser.parse(tsv)
        #expect(result.cards.count == 2)
        #expect(result.cards[0].front == "hello")
        #expect(result.cards[0].back == "world")
    }

    // MARK: - Header Detection

    @Test func skipsHeaderRow() {
        let csv = "Front,Back\nhello,world\nfoo,bar"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 2)
        #expect(result.cards[0].front == "hello")
    }

    @Test func skipsTermDefinitionHeader() {
        let csv = "Term,Definition\nhello,world"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 1)
        #expect(result.cards[0].front == "hello")
    }

    @Test func skipsQuestionAnswerHeader() {
        let tsv = "Question\tAnswer\nhello\tworld"
        let result = CSVParser.parse(tsv)
        #expect(result.cards.count == 1)
    }

    // MARK: - Edge Cases

    @Test func handlesEmptyFile() {
        let result = CSVParser.parse("")
        #expect(result.cards.isEmpty)
        #expect(!result.errors.isEmpty)
    }

    @Test func handlesBlankLines() {
        let csv = "hello,world\n\n\nfoo,bar\n"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 2)
    }

    @Test func handlesSingleColumnRow() {
        let csv = "hello,world\nsinglecolumn\nfoo,bar"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 2)
        #expect(result.skippedRows == 1)
    }

    @Test func handlesBOM() {
        let csv = "\u{FEFF}hello,world\nfoo,bar"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 2)
        #expect(result.cards[0].front == "hello")
    }

    // MARK: - Quoted Fields

    @Test func handlesQuotedFields() {
        let csv = "\"hello world\",\"foo bar\""
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 1)
        #expect(result.cards[0].front == "hello world")
        #expect(result.cards[0].back == "foo bar")
    }

    @Test func handlesEscapedQuotes() {
        let csv = "\"he said \"\"hello\"\"\",definition"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 1)
        #expect(result.cards[0].front == "he said \"hello\"")
    }

    @Test func handlesCommaInsideQuotes() {
        let csv = "\"hello, world\",definition"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 1)
        #expect(result.cards[0].front == "hello, world")
    }

    // MARK: - Trimming

    @Test func trimsWhitespace() {
        let csv = "  hello  ,  world  "
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 1)
        #expect(result.cards[0].front == "hello")
        #expect(result.cards[0].back == "world")
    }

    @Test func skipsEmptyFrontAndBack() {
        let csv = "hello,world\n , \nfoo,bar"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 2)
    }

    // MARK: - Delimiter Detection

    @Test func detectsTabDelimiter() {
        let tsv = "hello\tworld\tfoo\nbar\tbaz\tqux"
        let result = CSVParser.parse(tsv)
        #expect(result.cards.count == 2)
        #expect(result.cards[0].front == "hello")
        #expect(result.cards[0].back == "world")
    }

    @Test func detectsCommaDelimiter() {
        let csv = "hello,world,extra\nfoo,bar,baz"
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 2)
        #expect(result.cards[0].front == "hello")
    }

    // MARK: - Large Input

    @Test func handlesLargeFile() {
        var lines: [String] = []
        for i in 0..<1000 {
            lines.append("front\(i),back\(i)")
        }
        let csv = lines.joined(separator: "\n")
        let result = CSVParser.parse(csv)
        #expect(result.cards.count == 1000)
    }
}

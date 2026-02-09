//
//  KonitFlashTests.swift
//  KonitFlashTests
//
//  Created by GEUNIL on 2026/02/01.
//

import Testing
@testable import KonitFlash

struct KonitFlashTests {

    @Test func colorTagRawValues() {
        #expect(ColorTag.pink.rawValue == "pink")
        #expect(ColorTag.green.rawValue == "green")
    }

    @Test func colorTagFromRawValue() {
        #expect(ColorTag(rawValue: "pink") == .pink)
        #expect(ColorTag(rawValue: "green") == .green)
        #expect(ColorTag(rawValue: "invalid") == nil)
    }
}

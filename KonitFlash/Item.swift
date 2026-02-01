//
//  Item.swift
//  KonitFlash
//
//  Created by GEUNIL on 2026/02/01.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

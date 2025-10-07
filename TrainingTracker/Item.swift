//
//  Item.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/7/25.
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

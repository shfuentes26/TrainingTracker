//
//  Untitled.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//
import SwiftData
import Foundation

@Model
final class Item {
    var id: UUID = UUID()
    
    init(id: UUID = UUID()) {
            self.id = id
        }
}

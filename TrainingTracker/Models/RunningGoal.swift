//
//  RunningGoal.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/7/25.
//

import Foundation
import SwiftData

@Model
final class RunningGoal {
 
    var id: UUID
    var weekStart: Date
    var targetDistanceKm: Double
    var isActive: Bool
    //var notes: String?
    
    init(id: UUID, weekStart: Date, targetDistanceKm: Double, isActive: Bool) {
        self.id = id
        self.weekStart = weekStart
        self.targetDistanceKm = targetDistanceKm
        self.isActive = isActive
    }
    
    
}

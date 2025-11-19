//
//  GymGoal.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/7/25.
//

import Foundation
import SwiftData

@Model
final class GymGoal {
    
    var id: UUID
    var weekStart: Date
    var isActive: Bool
    //var notes: String? //tienen sentido en los goals??
    var muscleGoals: [GymMuscleGoal]
    
    init(id: UUID, weekStart: Date, isActive: Bool, muscleGoals: [GymMuscleGoal]) {
        self.id = id
        self.weekStart = weekStart
        self.isActive = isActive
        self.muscleGoals = muscleGoals
    }
    
}

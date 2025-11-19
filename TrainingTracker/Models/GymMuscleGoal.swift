//
//  GymMuscleGoal.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/7/25.
//

import Foundation
import SwiftData

@Model
final class GymMuscleGoal {
    
    var id: UUID
    var targetTrainings: Int
    var gymGroup: GymGroup

    init(id: UUID, targetTrainings: Int, gymGroup: GymGroup) {
        self.id = id
        self.targetTrainings = targetTrainings
        self.gymGroup = gymGroup
    }
    
}

//
//  Exercises.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/7/25.
//
import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var group: GymGroup
    var usesVariableWeight: Bool

    init(
        name: String,
        group: GymGroup,
        usesVariableWeight: Bool = true,
        id: UUID = UUID()
    ) {
        self.id = id
        self.name = name
        self.group = group
        self.usesVariableWeight = usesVariableWeight
    }
}

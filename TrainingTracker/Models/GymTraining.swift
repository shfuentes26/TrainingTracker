//
//  Untitled.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftData
import Foundation

@Model
final class GymTraining {
    var id: UUID
    var date: Date
    var notes: String?

    @Relationship var exercise: Exercise

    var reps: Int
    var weightKg: Double?

    init(
        exercise: Exercise,
        date: Date = .now,
        reps: Int,
        weightKg: Double? = nil,
        notes: String? = nil,
        id: UUID = UUID()
    ) {
        self.id = id
        self.date = date
        self.notes = notes
        self.exercise = exercise
        self.reps = reps
        self.weightKg = weightKg
    }
}

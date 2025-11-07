//
//  Untitled.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftData
import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    //Definimos 4 tipos de ejercicios de entrenamiento de gym
    case core = "Core",
         chestBack = "Chest/Back",
         arms = "Arms",
         legs = "Legs"
    var id: String { rawValue }
}

@Model
final class Exercise {
    var id: UUID
    var name: String
    var category: ExerciseCategory
    init(name: String, category: ExerciseCategory, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.category = category
    }
}

@Model
final class GymTraining {
    var date: Date
    var notes: String?
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSet] = []
    init(date: Date = .now, notes: String? = nil) {
        self.date = date
        self.notes = notes
    }
}

@Model
final class ExerciseSet {
    var exercise: Exercise
    var reps: Int
    var weightKg: Double
    weak var session: GymTraining?
    init(exercise: Exercise, reps: Int, weightKg: Double, session: GymTraining? = nil) {
        self.exercise = exercise
        self.reps = reps
        self.weightKg = weightKg
        self.session = session
    }
}

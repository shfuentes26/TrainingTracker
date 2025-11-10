//
//  ExerciseCategory.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//

enum GymGroup: String, Codable, CaseIterable, Identifiable {
    //Definimos 4 tipos de ejercicios de entrenamiento de gym
    case core = "Core",
         chestBack = "Chest/Back",
         arms = "Arms",
         legs = "Legs"
    var id: String { rawValue }
}

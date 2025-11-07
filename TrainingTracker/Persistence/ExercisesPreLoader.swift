//
//  ExercisesPreLoaded.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//
import SwiftData

enum ExercisesPreLoader {
    static func initialLoad(_ ctx: ModelContext) {
        // Carga inicial de ejercicios cuando no hay nada en DB
        let hasAny = (try? ctx.fetchCount(FetchDescriptor<Exercise>())) ?? 0 > 0
        guard !hasAny else { return }

        // Lista de ejercicios precargados
        let rows: [(String, ExerciseCategory)] = [
            // Core
            ("Abs", .core), ("Plank", .core),
            // Chest/Back
            ("Bench Press", .chestBack), ("Pull Up", .chestBack),("Push Up", .chestBack),
            // Arms
            ("Biceps Curl", .arms), ("Triceps Extension", .arms),
            // Legs
            ("Squats", .legs), ("Lunges", .legs), ("Calf Raises", .legs)
        ]

        for (name, cat) in rows {
            ctx.insert(Exercise(name: name, category: cat))
        }
        try? ctx.save()
    }
}

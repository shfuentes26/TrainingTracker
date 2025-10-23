//
//  TrainingTrackerApp.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/7/25.
//

import SwiftUI
import SwiftData

@main
struct TrainingTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            GymTraining.self,
            ExerciseSet.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Exercise.self,
                              GymTraining.self,
                              ExerciseSet.self])
    }
}

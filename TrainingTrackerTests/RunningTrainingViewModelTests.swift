//
//  RunningTrainingViewModelTests.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/14/25.
//
import Testing
import SwiftData
import Foundation
@testable import TrainingTracker

@MainActor
struct RunningTrainingViewModelTests {

    private func makeContext() throws -> ModelContext {
        //Usamos el contenedor en memoria para evitar conflictos con datos ya almacenados en SwiftData
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self, GymTraining.self, RunningTraining.self,
            configurations: config
        )
        return ModelContext(container)
    }

    
}


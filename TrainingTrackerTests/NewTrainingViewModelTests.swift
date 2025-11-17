//
//  NewTrainingViewModelTests.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/17/25.
//

import Testing
import SwiftData
import Foundation
@testable import TrainingTracker


@MainActor
struct NewTrainingViewModelTests {
    
    
    //Test de GYM
    private func makeContext() throws -> ModelContext {
        //Usamos el contenedor en memoria para evitar conflictos con datos ya almacenados en SwiftData
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self, GymTraining.self, RunningTraining.self,
            configurations: config
        )
        return ModelContext(container)
    }
    
    private func insertExercise(in context: ModelContext) -> Exercise {
        let exercise = Exercise(name: "Bench Press", group: .chestBack)
        context.insert(exercise)
        return exercise
    }
    
    @Test
    func canSaveGym() async throws {
        let vm = NewTrainingViewModel()
        
        vm.repsText = ""
        vm.selectedExerciseID = nil
        #expect(vm.canSaveGym == false)
        
        vm.repsText = "10"
        vm.selectedExerciseID = nil
        #expect(vm.canSaveGym == false)
        
        vm.repsText = ""
        vm.selectedExerciseID = UUID()
        #expect(vm.canSaveGym == false)
        
        vm.repsText = "10"
        vm.selectedExerciseID = UUID()
        #expect(vm.canSaveGym == true)
    }
    
    @Test
    func saveGymTrainingSuccessful() async throws {
        let context = try makeContext()
        let exercise = insertExercise(in: context)
        
        let vm = NewTrainingViewModel()
        vm.date = Date(timeIntervalSince1970: 0)
        vm.category = .chestBack
        vm.selectedExerciseID = exercise.id
        vm.repsText = "12"
        vm.weightText = "40"
        vm.notes = "Test gym"
        
        let saved = vm.saveGymTraining(
            context: context,
            exerciseByID: { id in
                try? context
                    .fetch(FetchDescriptor<Exercise>())
                    .first(where: { $0.id == id })
            }
        )
        
        #expect(saved == true)
        
        let trainings = try context.fetch(FetchDescriptor<GymTraining>())
        #expect(trainings.count == 1)
        
        let training = try #require(trainings.first)
        #expect(training.exercise.id == exercise.id)
        #expect(training.reps == 12)
        #expect(training.weightKg == 40)
        #expect(training.notes == "Test gym")
    }
    
    @Test
    func resetForm() async throws {
        let vm = NewTrainingViewModel()
        
        vm.date = Date(timeIntervalSince1970: 0)
        vm.selectedExerciseID = UUID()
        vm.repsText = "10"
        vm.weightText = "40"
        vm.notes = "Test gym"
        
        vm.resetForm()
        
        #expect(vm.selectedExerciseID == nil)
        #expect(vm.repsText.isEmpty)
        #expect(vm.weightText.isEmpty)
        #expect(vm.notes.isEmpty)
    }
    
    //RUNNING tests
    @Test
    func applyDurationMaskFormatsCorrectly() async throws {
        let vm = NewTrainingViewModel()

        let masked = vm.applyDurationMask("04530")
        #expect(masked == "0:45:30")

    }

    @Test
    func canSaveRunning() async throws {
        let vm = NewTrainingViewModel()

        // Todo vacío
        #expect(vm.canSaveRunning == false)

        // Solo distancia
        vm.distanceText = "5"
        vm.durationText = ""
        #expect(vm.canSaveRunning == false)

        // Solo duración
        vm.distanceText = ""
        vm.durationText = "04530"
        #expect(vm.canSaveRunning == false)

        // Ambos válidos
        vm.distanceText = "5"
        vm.durationText = "04530"
        #expect(vm.canSaveRunning == true)
    }

    @Test
    func saveRunningTrainingSuccessful() async throws {
        let context = try makeContext()
        let vm = NewTrainingViewModel()

        vm.date = Date(timeIntervalSince1970: 0)
        vm.distanceText = "5"
        vm.durationText = vm.applyDurationMask("04530")
        vm.notes = "Test run"

        vm.save(using: context)

        let descriptor = FetchDescriptor<RunningTraining>()
        let runs = try context.fetch(descriptor)

        // obtenemos el training que acabamos de crear
        let run = try #require(
            runs.first(where: { $0.distanceKm == 5 })
        )

        // Comprobamos sus valores
        #expect(run.distanceKm == 5)
        #expect(run.durationSec == 2730)
        #expect(run.notes == "Test run")

        // El formulario debe haberse reseteado
        #expect(vm.distanceText.isEmpty)
        #expect(vm.durationText.isEmpty)
        #expect(vm.notes.isEmpty)

        // Y debe mostrar el alert de éxito
        let alert = try #require(vm.alert)
        #expect(alert.title == "Saved")
    }
    
    
}

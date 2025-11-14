//
//  GymTrainingViewModelTests.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/14/25.
//

import Testing
import SwiftData
import Foundation
@testable import TrainingTracker


@MainActor
struct GymTrainingViewModelTests {

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
        let vm = GymTrainingViewModel()

        vm.repsText = ""
        vm.selectedExerciseID = nil
        #expect(vm.canSave == false)

        vm.repsText = "10"
        vm.selectedExerciseID = nil
        #expect(vm.canSave == false)

        vm.repsText = ""
        vm.selectedExerciseID = UUID()
        #expect(vm.canSave == false)

        vm.repsText = "10"
        vm.selectedExerciseID = UUID()
        #expect(vm.canSave == true)
    }

    @Test
    func saveGymTrainingSuccessful() async throws {
        let context = try makeContext()
        let exercise = insertExercise(in: context)

        let vm = GymTrainingViewModel()
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
        let vm = GymTrainingViewModel()

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
}


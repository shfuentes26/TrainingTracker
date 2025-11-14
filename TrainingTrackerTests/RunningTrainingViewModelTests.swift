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

    @Test
    func applyDurationMaskFormatsCorrectly() async throws {
        let vm = RunningTrainingViewModel()

        let masked = vm.applyDurationMask("04530")
        #expect(masked == "0:45:30")

    }

    @Test
    func canSaveRunning() async throws {
        let vm = RunningTrainingViewModel()

        // Todo vacío
        #expect(vm.canSave == false)

        // Solo distancia
        vm.distanceText = "5"
        vm.durationText = ""
        #expect(vm.canSave == false)

        // Solo duración
        vm.distanceText = ""
        vm.durationText = "04530"
        #expect(vm.canSave == false)

        // Ambos válidos
        vm.distanceText = "5"
        vm.durationText = "04530"
        #expect(vm.canSave == true)
    }

    @Test
    func saveRunningTrainingSuccessful() async throws {
        let context = try makeContext()
        let vm = RunningTrainingViewModel()

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


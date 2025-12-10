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
        // Usamos el contenedor en memoria para evitar conflictos con datos ya almacenados en SwiftData
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self, GymTraining.self, RunningTraining.self,
            configurations: config
        )
        return ModelContext(container)
    }

    ///verifica el comportamiento del ViewModel cuando no existen entrenamientos
    @Test
    func loadWithNoTrainingsProducesEmptyListAndZeroDistances() async throws {
        let context = try makeContext()
        let vm = RunningTrainingViewModel()

        UserDefaults.standard.set(false, forKey: "useMiles")

        vm.load(context: context)

        // Lista vacía
        #expect(vm.items.isEmpty)

        // 12 meses con distancia 0
        let distances = vm.monthlyDistances(for: vm.selectedYear)

        #expect(distances.count == 12)
        #expect(distances.allSatisfy { $0.totalKm == 0 })
        #expect(distances.map(\.month) == Array(1...12))
    }

    ///Verifica que load(context:) agrega correctamente las distancias mensuales.
    @Test
    func loadAggregatesMonthlyDistancesCorrectly() async throws {
        let context = try makeContext()
        let vm = RunningTrainingViewModel()

        UserDefaults.standard.set(false, forKey: "useMiles")

        let calendar = Calendar.current

        let nov1 = calendar.date(from: DateComponents(year: 2025, month: 11, day: 1))!
        let nov2 = calendar.date(from: DateComponents(year: 2025, month: 11, day: 15))!
        let jan  = calendar.date(from: DateComponents(year: 2025, month: 1,  day: 10))!

        context.insert(RunningTraining(date: nov1, distanceKm: 5, durationSec: 1500, notes: nil))
        context.insert(RunningTraining(date: nov2, distanceKm: 3, durationSec: 1000, notes: nil))
        context.insert(RunningTraining(date: jan,  distanceKm: 10, durationSec: 3600, notes: nil))

        try context.save()

        vm.load(context: context)

        let distances = vm.monthlyDistances(for: 2025)
        
        #expect(distances.count == 12)

        let january = try #require(distances.first(where: { $0.month == 1 }))
        let november = try #require(distances.first(where: { $0.month == 11 }))

        #expect(january.totalKm == 10)
        #expect(november.totalKm == 8)
                
    }

    ///Verifica que load(context:) construye items correctamente para la lista de runnings
    @Test
    func loadBuildsItemsSortedByDateAndFormatsSubtitle() async throws {
        let context = try makeContext()
        let vm = RunningTrainingViewModel()

        UserDefaults.standard.set(false, forKey: "useMiles")

        let calendar = Calendar.current
        let older = calendar.date(from: DateComponents(year: 2025, month: 10, day: 1))!
        let newer = calendar.date(from: DateComponents(year: 2025, month: 11, day: 1))!

        context.insert(RunningTraining(date: newer, distanceKm: 5, durationSec: 1500, notes: nil))
        context.insert(RunningTraining(date: older, distanceKm: 2, durationSec: 600, notes: nil))

        try context.save()

        vm.load(context: context)

        #expect(vm.items.count == 2)

        // Ordenados desc por fecha
        let first = try #require(vm.items.first)
        #expect(first.date == newer)

        #expect(first.subtitle == "5.0 km • 5:00 min/km")
    }
}



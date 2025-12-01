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
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self, GymTraining.self, RunningTraining.self,
            configurations: config
        )
        return ModelContext(container)
    }

    private func makeExercise(name: String, group: GymGroup, in context: ModelContext) -> Exercise {
        let ex = Exercise(name: name, group: group)
        context.insert(ex)
        return ex
    }

    @Test
    func loadWithNoTrainingsProducesEmptyListAndZeroCounts() async throws {
        let context = try makeContext()
        let vm = GymTrainingViewModel()

        UserDefaults.standard.set(false, forKey: "usePounds")

        vm.load(context: context)

        #expect(vm.items.isEmpty)

        // 12 meses, cada uno con un count 0
        #expect(vm.monthlyGymCounts.count == 12)
        #expect(vm.monthlyGymCounts.allSatisfy { $0.count == 0 })
        #expect(vm.monthlyGymCounts.map(\.month) == Array(1...12))
    }

    @Test
    func loadAggregatesCountsByMonthAndGroup() async throws {
        let context = try makeContext()
        let vm = GymTrainingViewModel()

        UserDefaults.standard.set(false, forKey: "usePounds")

        let calendar = Calendar.current

        let exArms = makeExercise(name: "Biceps Curl", group: .arms, in: context)
        let exCore = makeExercise(name: "Plank",       group: .core, in: context)

        let nov1 = calendar.date(from: DateComponents(year: 2025, month: 11, day: 1))!
        let nov2 = calendar.date(from: DateComponents(year: 2025, month: 11, day: 10))!
        let jan  = calendar.date(from: DateComponents(year: 2025, month: 1,  day: 5))!

        // Nov: 2 entrenos (1 arms, 1 core)
        context.insert(GymTraining(exercise: exArms, date: nov1, reps: 10, weightKg: 40, notes: nil))
        context.insert(GymTraining(exercise: exCore, date: nov2, reps: 20, weightKg: nil, notes: nil))

        // Ene: 1 entreno core
        context.insert(GymTraining(exercise: exCore, date: jan, reps: 15, weightKg: nil, notes: nil))

        try context.save()

        vm.load(context: context)

        // Debe haber 12 meses (algunos con 0)
        #expect(vm.monthlyGymCounts.map(\.month).contains(11))
        #expect(vm.monthlyGymCounts.map(\.month).contains(1))

        let novemberArms = try #require(
            vm.monthlyGymCounts.first(where: { $0.month == 11 && $0.group == .arms })
        )
        let novemberCore = try #require(
            vm.monthlyGymCounts.first(where: { $0.month == 11 && $0.group == .core })
        )
        let januaryCore = try #require(
            vm.monthlyGymCounts.first(where: { $0.month == 1 && $0.group == .core })
        )

        #expect(novemberArms.count == 1)
        #expect(novemberCore.count == 1)
        #expect(januaryCore.count == 1)
    }

    @Test
    func loadBuildsItemsSortedByDateAndFormatsSubtitle() async throws {
        let context = try makeContext()
        let vm = GymTrainingViewModel()

        UserDefaults.standard.set(false, forKey: "usePounds")

        let calendar = Calendar.current
        let ex = makeExercise(name: "Bench Press", group: .chestBack, in: context)

        let older = calendar.date(from: DateComponents(year: 2025, month: 10, day: 1))!
        let newer = calendar.date(from: DateComponents(year: 2025, month: 11, day: 1))!

        // newer con peso, older sin peso
        context.insert(GymTraining(exercise: ex, date: newer, reps: 12, weightKg: 40, notes: nil))
        context.insert(GymTraining(exercise: ex, date: older, reps: 8,  weightKg: nil, notes: nil))

        try context.save()

        vm.load(context: context)

        #expect(vm.items.count == 2)

        let first = try #require(vm.items.first)
        #expect(first.date == newer)
        #expect(first.subtitle == "Bench Press • 12 reps @ 40.0 kg")
    }

    @Test
    func deleteRemovesTrainingAndReloadsItems() async throws {
        let context = try makeContext()
        let vm = GymTrainingViewModel()

        UserDefaults.standard.set(false, forKey: "usePounds")

        let ex = makeExercise(name: "Squat", group: .legs, in: context)
        let date = Date(timeIntervalSince1970: 0)

        let training = GymTraining(exercise: ex, date: date, reps: 10, weightKg: 50, notes: nil)
        context.insert(training)
        try context.save()

        vm.load(context: context)
        let item = try #require(vm.items.first)
        #expect(vm.items.count == 1)

        vm.delete(item, in: context)

        // Debe haberse eliminado del contexto y de la lista del VM
        let trainings = try context.fetch(FetchDescriptor<GymTraining>())
        #expect(trainings.isEmpty)
        #expect(vm.items.isEmpty)
    }
   
}


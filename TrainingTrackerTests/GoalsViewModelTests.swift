//
//  GoalsViewModelTests.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 12/10/25.
//

import Testing
import SwiftData
import Foundation
@testable import TrainingTracker

@MainActor
struct GoalsViewModelTests {

    /// Crea un ModelContext en memoria
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for:
                Exercise.self,
                GymTraining.self,
                RunningTraining.self,
                RunningGoal.self,
                GymGoal.self,
                GymMuscleGoal.self,
            configurations: config
        )
        return ModelContext(container)
    }

    /// Helper para generar fechas consistentes dentro de la semana actual.
    private func currentWeekStart() -> Date {
        let calendar = Calendar.current
        let now = Date()
        if let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) {
            return start
        }
        return now
    }

    /// Inserta un Exercise para crear GymTraining en tests de summary.
    @discardableResult
    private func insertExercise(
        name: String,
        group: GymGroup,
        in context: ModelContext
    ) -> Exercise {
        let ex = Exercise(name: name, group: group)
        context.insert(ex)
        return ex
    }

    /// Verifica que load(context:) carga un RunningGoal activo de la semana actual.
    @Test
    func loadRunningGoal_whenExists_populatesText() async throws {
        let context = try makeContext()
        let vm = GoalsViewModel()

        let weekStart = currentWeekStart()

        let goal = RunningGoal(
            id: UUID(),
            weekStart: weekStart,
            targetDistanceKm: 12.5,
            isActive: true
        )
        context.insert(goal)
        try context.save()

        vm.load(context: context)

        #expect(vm.runningDistanceText == "12.5")
    }

    ///Verifica que, si no hay GymGoal activo esta semana el VM resetea todos los contadores a 0 en el goal.
    @Test
    func loadGymGoal_whenMissing_setsAllCountsToZero() async throws {
        let context = try makeContext()
        let vm = GoalsViewModel()

        vm.load(context: context)

        #expect(vm.chestBackCount == 0)
        #expect(vm.armsCount == 0)
        #expect(vm.legsCount == 0)
        #expect(vm.coreCount == 0)
    }

    ///Verifica que saveRunningGoal(context:) normaliza coma/punto y persiste correctamente la distancia.
    @Test
    func saveRunningGoal_withComma_parsesAndPersists() async throws {
        let context = try makeContext()
        let vm = GoalsViewModel()

        vm.runningDistanceText = "5,5"

        vm.saveRunningGoal(context: context)

        let goals = try context.fetch(FetchDescriptor<RunningGoal>())
        #expect(goals.count == 1)

        let saved = try #require(goals.first)
        #expect(saved.targetDistanceKm == 5.5)
        #expect(saved.isActive == true)
    }

    ///Verifica que saveRunningGoal(context:) elimina el goal existente cuando la distancia introducida es 0
    @Test
    func saveRunningGoal_withZero_deletesExisting() async throws {
        let context = try makeContext()
        let vm = GoalsViewModel()
        let weekStart = currentWeekStart()

        // Insertamos un goal existente de la semana
        let goal = RunningGoal(
            id: UUID(),
            weekStart: weekStart,
            targetDistanceKm: 10,
            isActive: true
        )
        context.insert(goal)
        try context.save()

        // Cargamos para que runningGoal interno quede enlazado
        vm.load(context: context)
        #expect(vm.runningDistanceText == "10.0")

        // Distancia inválida -> debe eliminar
        vm.runningDistanceText = "0"
        vm.saveRunningGoal(context: context)

        let goals = try context.fetch(FetchDescriptor<RunningGoal>())
        #expect(goals.isEmpty)
        #expect(vm.runningDistanceText.isEmpty)
    }


    ///Verifica que saveGymGoal elimina el goal existente cuando todos los grupos tienen 0 ejercicios
    @Test
    func saveGymGoal_withAllZero_deletesExisting() async throws {
        let context = try makeContext()
        let vm = GoalsViewModel()
        let weekStart = currentWeekStart()

        // Creamos un goal con muscleGoals
        let goal = GymGoal(
            id: UUID(),
            weekStart: weekStart,
            isActive: true,
            muscleGoals: [
                GymMuscleGoal(id: UUID(), targetTrainings: 2, gymGroup: .chestBack),
                GymMuscleGoal(id: UUID(), targetTrainings: 1, gymGroup: .arms)
            ]
        )
        context.insert(goal)
        try context.save()

        // Cargamos para enlazar gymGoal interno
        vm.load(context: context)

        // Forzamos total == 0
        vm.chestBackCount = 0
        vm.armsCount = 0
        vm.legsCount = 0
        vm.coreCount = 0

        vm.saveGymGoal(context: context)

        let goals = try context.fetch(FetchDescriptor<GymGoal>())
        #expect(goals.isEmpty)

        #expect(vm.chestBackCount == 0)
        #expect(vm.armsCount == 0)
        #expect(vm.legsCount == 0)
        #expect(vm.coreCount == 0)
    }

    ///Verifica que saveGymGoal(context:) crea o actualiza un GymGoal si el total es mayor que 0
    @Test
    func saveGymGoal_createsOrUpdatesMuscleGoalsForAllGroups() async throws {
        let context = try makeContext()
        let vm = GoalsViewModel()

        vm.chestBackCount = 2
        vm.armsCount = 1
        vm.legsCount = 3
        vm.coreCount = 0

        vm.saveGymGoal(context: context)

        let goals = try context.fetch(FetchDescriptor<GymGoal>())
        #expect(goals.count == 1)

        let saved = try #require(goals.first)
        #expect(saved.isActive == true)

        func target(_ group: GymGroup) -> Int {
            saved.muscleGoals.first(where: { $0.gymGroup == group })?.targetTrainings ?? -1
        }

        #expect(target(.chestBack) == 2)
        #expect(target(.arms) == 1)
        #expect(target(.legs) == 3)
        #expect(target(.core) == 0)
    }

    /// Verifica que reloadSummary(context:) calcula correctamente el resumen semanal de running y gym.
    @Test
    func currentWeekSummary_countsDoneAndTargetsCorrectly() async throws {
        let context = try makeContext()
        let vm = GoalsViewModel()

        let weekStart = currentWeekStart()
        let calendar = Calendar.current

        // Goals de la semana
        let runGoal = RunningGoal(
            id: UUID(),
            weekStart: weekStart,
            targetDistanceKm: 15,
            isActive: true
        )
        context.insert(runGoal)

        let gymGoal = GymGoal(
            id: UUID(),
            weekStart: weekStart,
            isActive: true,
            muscleGoals: [
                GymMuscleGoal(id: UUID(), targetTrainings: 2, gymGroup: .chestBack),
                GymMuscleGoal(id: UUID(), targetTrainings: 1, gymGroup: .arms),
                GymMuscleGoal(id: UUID(), targetTrainings: 1, gymGroup: .legs),
                GymMuscleGoal(id: UUID(), targetTrainings: 0, gymGroup: .core)
            ]
        )
        context.insert(gymGoal)

        // Entrenamientos de running dentro de la semana
        let runDate1 = calendar.date(byAdding: .day, value: 1, to: weekStart) ?? weekStart
        let runDate2 = calendar.date(byAdding: .day, value: 3, to: weekStart) ?? weekStart

        let r1 = RunningTraining(date: runDate1, distanceKm: 5, durationSec: 1500, notes: nil)
        let r2 = RunningTraining(date: runDate2, distanceKm: 4, durationSec: 1200, notes: nil)
        context.insert(r1)
        context.insert(r2)

        // Entrenamientos de gym dentro de la semana
        let exChest = insertExercise(name: "Bench", group: .chestBack, in: context)
        let exArms  = insertExercise(name: "Curl", group: .arms, in: context)
        let exLegs  = insertExercise(name: "Squat", group: .legs, in: context)

        let gymDate = calendar.date(byAdding: .day, value: 2, to: weekStart) ?? weekStart
        context.insert(GymTraining(exercise: exChest, date: gymDate, reps: 10, weightKg: 50, notes: nil))
        context.insert(GymTraining(exercise: exChest, date: gymDate, reps: 8, weightKg: 52, notes: nil))
        context.insert(GymTraining(exercise: exArms,  date: gymDate, reps: 12, weightKg: 15, notes: nil))
        context.insert(GymTraining(exercise: exLegs,  date: gymDate, reps: 10, weightKg: 80, notes: nil))

        try context.save()

        // Recargamos summary desde el VM
        vm.reloadSummary(context: context)

        let running = try #require(vm.summary.running)
        #expect(running.targetKm == 15)
        #expect(running.doneKm == 9) // 5 + 4

        let gym = try #require(vm.summary.gym)
        #expect(gym.chestTarget == 2)
        #expect(gym.armsTarget == 1)
        #expect(gym.legsTarget == 1)
        #expect(gym.coreTarget == 0)

        #expect(gym.chestDone == 2)
        #expect(gym.armsDone == 1)
        #expect(gym.legsDone == 1)
        #expect(gym.coreDone == 0)

        #expect(gym.totalTarget == 4)
        #expect(gym.totalDone == 4)
    }
}

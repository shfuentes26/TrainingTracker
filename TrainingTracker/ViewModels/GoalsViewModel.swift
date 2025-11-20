//
//  GoalsViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/18/25.
//

import Foundation
import SwiftData


/// View Model para gestionar goals. 
@MainActor
final class GoalsViewModel: ObservableObject {

    @Published var runningDistanceText: String = ""
    @Published var chestBackCount: Int = 0
    @Published var armsCount: Int = 0
    @Published var legsCount: Int = 0
    @Published var coreCount: Int = 0
    
    @Published var summary: Summary = .init(running: nil, gym: nil)

    private var runningGoal: RunningGoal?
    private var gymGoal: GymGoal?

    /// Carga los goals actuales (running + gym) desde la base de datos
    func load(context: ModelContext) {
        loadRunningGoal(context: context)
        loadGymGoal(context: context)
    }
    /// Busca si existe un RunningGoal activo para la semana actual.
    private func loadRunningGoal(context: ModelContext) {
        let weekStart = Self.startOfCurrentWeek()

        let predicate = #Predicate<RunningGoal> { goal in
            goal.weekStart == weekStart && goal.isActive == true
        }
        var descriptor = FetchDescriptor<RunningGoal>(predicate: predicate)
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            runningGoal = existing
            runningDistanceText = Self.formatDistance(existing.targetDistanceKm)
        } else {
            runningGoal = nil
            runningDistanceText = ""
        }
    }
    /// Guarda o elimina el RunningGoal según el valor introducido.
    func saveRunningGoal(context: ModelContext) {
        let weekStart = Self.startOfCurrentWeek()

        // Normalizamos coma/punto
        let cleaned = runningDistanceText.replacingOccurrences(of: ",", with: ".")
        let distanceKm = Double(cleaned) ?? 0
        
        if distanceKm <= 0 {
            if let goal = runningGoal {
                context.delete(goal)
                runningGoal = nil
            }
            runningDistanceText = ""
            do {
                try context.save()
            } catch {
                print("Error deleting RunningGoal: \(error)")
            }
            return
        }

        if let goal = runningGoal {
            goal.weekStart = weekStart
            goal.targetDistanceKm = distanceKm
            goal.isActive = true
        } else {
            let new = RunningGoal(
                id: UUID(),
                weekStart: weekStart,
                targetDistanceKm: distanceKm,
                isActive: true
            )
            context.insert(new)
            runningGoal = new
        }

        print("saveRunningGoal() text=\(runningDistanceText) -> km=\(distanceKm)")
        do {
            try context.save()
            // TODO: eliminar esto despues de las pruebas
            //let allRunning = try context.fetch(FetchDescriptor<RunningGoal>())
            //let allGym     = try context.fetch(FetchDescriptor<GymGoal>())
            //print("HomeViewModel despues de guardar en DB -> runningGoals=\(allRunning.count), gymGoals=\(allGym.count)")x
            
        } catch {
            print("Error saving RunningGoal: \(error)")
        }
    }

    /// Carga el GymGoal activo para esta semana desde la BD.
    private func loadGymGoal(context: ModelContext) {
        let weekStart = Self.startOfCurrentWeek()

        let predicate = #Predicate<GymGoal> { goal in
            goal.weekStart == weekStart && goal.isActive == true
        }
        var descriptor = FetchDescriptor<GymGoal>(predicate: predicate)
        descriptor.fetchLimit = 1

        guard let existing = try? context.fetch(descriptor).first else {
            gymGoal = nil
            chestBackCount = 0
            armsCount = 0
            legsCount = 0
            coreCount = 0
            return
        }

        gymGoal = existing

        func value(for group: GymGroup) -> Int {
            existing.muscleGoals.first(where: { $0.gymGroup == group })?.targetTrainings ?? 0
        }

        chestBackCount = value(for: .chestBack)
        armsCount      = value(for: .arms)
        legsCount      = value(for: .legs)
        coreCount      = value(for: .core)
    }
    /// Guarda o elimina el GymGoal según los valores introducidos.
    func saveGymGoal(context: ModelContext) {
        let weekStart = Self.startOfCurrentWeek()

        let values: [(GymGroup, Int)] = [
            (.chestBack, chestBackCount),
            (.arms,      armsCount),
            (.legs,      legsCount),
            (.core,      coreCount)
        ]
        
        //logica para eliminar goal de gym
        let total = chestBackCount + armsCount + legsCount + coreCount
        if total == 0 {
            if let existing = gymGoal {
                context.delete(existing)
                gymGoal = nil
            }
            chestBackCount = 0
            armsCount      = 0
            legsCount      = 0
            coreCount      = 0
            do {
                try context.save()
            } catch {
                print("Error deleting GymGoal: \(error)")
            }
            return
        }

        let goal: GymGoal

        if let existing = gymGoal {
            goal = existing
            goal.weekStart = weekStart
            goal.isActive = true
        } else {
            goal = GymGoal(id: UUID(), weekStart: weekStart, isActive: true, muscleGoals: [])
            context.insert(goal)
            gymGoal = goal
        }

        // Creamos GymMuscleGoal por grupo
        for (group, count) in values {
            if let muscle = goal.muscleGoals.first(where: { $0.gymGroup == group }) {
                muscle.targetTrainings = count
            } else {
                let muscle = GymMuscleGoal(
                    id: UUID(),
                    targetTrainings: count,
                    gymGroup: group
                )
                goal.muscleGoals.append(muscle)
            }
        }
        print("saveGymGoal(). counts = CB:\(chestBackCount) Arms:\(armsCount) Legs:\(legsCount) Core:\(coreCount)")
        do {
            try context.save()
            // TODO: eliminar esto despues de las pruebas
            //let allRunning = try context.fetch(FetchDescriptor<RunningGoal>())
            //let allGym     = try context.fetch(FetchDescriptor<GymGoal>())
            //print("HomeViewModel despues de guardar en DB -> runningGoals=\(allRunning.count), gymGoals=\(allGym.count)")

        } catch {
            print("Error saving GymGoal: \(error)")
        }
    }

    /// Devuelve el primer día de la semana actual
    private static func startOfCurrentWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        if let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) {
            return start
        }
        return now
    }
    /// Convierte un double a string con un decimal.
    private static func formatDistance(_ km: Double) -> String {
        if km == 0 { return "" }
        return String(format: "%.1f", km)
    }
    
    /// Recarga el summary de la semana actual desde la BD
    func reloadSummary(context: ModelContext) {
        summary = Self.currentWeekSummary(context: context)
    }
    
    ///objeto summary de goals para el UI
    struct Summary {
        struct Running {
            let doneKm: Double
            let targetKm: Double
        }

        struct Gym {
            let chestDone: Int
            let chestTarget: Int
            let armsDone: Int
            let armsTarget: Int
            let legsDone: Int
            let legsTarget: Int
            let coreDone: Int
            let coreTarget: Int

            var totalDone: Int {
                chestDone + armsDone + legsDone + coreDone
            }

            var totalTarget: Int {
                chestTarget + armsTarget + legsTarget + coreTarget
            }
        }

        let running: Running?
        let gym: Gym?
    }
            
    /// metodo para devolver el resumen semanal del goal
    static func currentWeekSummary(context: ModelContext) -> Summary {
        let weekStart = startOfCurrentWeek()
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart

        var runningSummary: Summary.Running? = nil
        var gymSummary: Summary.Gym? = nil

        // RUNNING: goal + distancia acumulada semana
        do {
            // goal de la semana actual
            let goalPredicate = #Predicate<RunningGoal> { goal in
                goal.weekStart == weekStart && goal.isActive == true
            }
            var goalDescriptor = FetchDescriptor<RunningGoal>(predicate: goalPredicate)
            goalDescriptor.fetchLimit = 1

            if let goal = try context.fetch(goalDescriptor).first {
                let targetKm = goal.targetDistanceKm

                // acumulado de la semana en RunningTraining
                let trainingsPredicate = #Predicate<RunningTraining> { run in
                    run.date >= weekStart && run.date < weekEnd
                }
                let trainingsDescriptor = FetchDescriptor<RunningTraining>(predicate: trainingsPredicate)

                let runs = try context.fetch(trainingsDescriptor)
                let doneKm = runs.reduce(0.0) { $0 + $1.distanceKm }

                runningSummary = .init(doneKm: doneKm, targetKm: targetKm)
            }
        } catch {
            print("Error fetching RunningGoal / RunningTraining summary: \(error)")
        }

        // GYM: goal + numero de entrenamientos por grupo en la semana
        do {
            let goalPredicate = #Predicate<GymGoal> { goal in
                goal.weekStart == weekStart && goal.isActive == true
            }
            var goalDescriptor = FetchDescriptor<GymGoal>(predicate: goalPredicate)
            goalDescriptor.fetchLimit = 1

            if let goal = try context.fetch(goalDescriptor).first {
                // objetivos por grupo
                func target(_ group: GymGroup) -> Int {
                    goal.muscleGoals.first(where: { $0.gymGroup == group })?.targetTrainings ?? 0
                }
                let chestTarget = target(.chestBack)
                let armsTarget  = target(.arms)
                let legsTarget  = target(.legs)
                let coreTarget  = target(.core)

                // acumulado de Gym de la semana
                let trainingsPredicate = #Predicate<GymTraining> { training in
                    training.date >= weekStart && training.date < weekEnd
                }
                let trainingsDescriptor = FetchDescriptor<GymTraining>(predicate: trainingsPredicate)
                let trainings = try context.fetch(trainingsDescriptor)

                var chestDone = 0
                var armsDone  = 0
                var legsDone  = 0
                var coreDone  = 0

                for t in trainings {
                    let group = t.exercise.group
                    switch group {
                    case .chestBack: chestDone += 1
                    case .arms:      armsDone  += 1
                    case .legs:      legsDone  += 1
                    case .core:      coreDone  += 1
                    }
                }

                gymSummary = .init(
                    chestDone: chestDone, chestTarget: chestTarget,
                    armsDone: armsDone,   armsTarget: armsTarget,
                    legsDone: legsDone,   legsTarget: legsTarget,
                    coreDone: coreDone,   coreTarget: coreTarget
                )
            }
        } catch {
            print("Error fetching GymGoal / GymTraining summary: \(error)")
        }

        return Summary(running: runningSummary, gym: gymSummary)
    }
}

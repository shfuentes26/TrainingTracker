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
        let running: String?
        let gym: String?
    }
    /// metodo para devolver el resumen semanal del goal
    static func currentWeekSummary(context: ModelContext) -> Summary {
        //let weekStart = startOfCurrentWeek()

        var runningText: String? = nil
        var gymText: String? = nil

        // RunningGoal
        do {
            var descriptor = FetchDescriptor<RunningGoal>()
            descriptor.fetchLimit = 1
            print("before the fetch")
            if let goal = try context.fetch(descriptor).first {
                let distance = formatDistance(goal.targetDistanceKm)
                runningText = "Running: \(distance) km per week"
                print("GoalsViewModel!! distance=\(runningText ?? "nil")")
            }
        } catch {
            print("Error fetching RunningGoal summary: \(error)")
        }

        // GymGoal
        do {
            var descriptor = FetchDescriptor<GymGoal>()
            descriptor.fetchLimit = 1

            if let goal = try context.fetch(descriptor).first {
                func count(_ group: GymGroup) -> Int {
                    goal.muscleGoals.first(where: { $0.gymGroup == group })?.targetTrainings ?? 0
                }
                let chest = count(.chestBack)
                let arms  = count(.arms)
                let legs  = count(.legs)
                let core  = count(.core)
                //TODO: pruebas para ver el progreso en formato texto
                gymText = "Gym: CB \(chest) · Arms \(arms) · Legs \(legs) · Core \(core)"
            }
        } catch {
            print("Error fetching GymGoal summary: \(error)")
        }

        return Summary(running: runningText, gym: gymText)
    }
}

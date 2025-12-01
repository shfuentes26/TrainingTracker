//
//  GymTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/23/25.
//
import Foundation
import SwiftUI
import SwiftData

/// ViewModel responsable de la home de entrenamientos de gimnasio
@MainActor
final class GymTrainingViewModel: ObservableObject {

    @Published var items: [HomeItem] = []
    @Published var monthlyGymCounts: [MonthlyGymCount] = []
    
    //objeto para preparar data para el chart
    struct MonthlyGymCount: Identifiable {
        let id = UUID()
        let month: Int
        let group: GymGroup
        let count: Int
    }

    /// Carga todos los entrenamientos de gym desde SwiftData.
    func load(context: ModelContext) {
        // Preferencia de unidades de peso
        let usePounds = UserDefaults.standard.bool(forKey: "usePounds")

        // Fetch de entrenamientos de Gym ordenados por fecha descendente
        let gymDesc = FetchDescriptor<GymTraining>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let gyms = (try? context.fetch(gymDesc)) ?? []

        var gymItems: [HomeItem] = []
        var monthlyByGroup: [Int: [GymGroup: Int]] = [:]

        //Recorremos entrenos y acumulamos por mes y grupo
        for g in gyms {
            let details: String = {
                if let w = g.weightKg {
                    return "\(g.exercise.name) • \(g.reps) reps @ \(weightString(w, usePounds: usePounds))"
                } else {
                    return "\(g.exercise.name) • \(g.reps) reps"
                }
            }()

            // Acumulamos num de entrenamientos por mes y grupo
            let month = Calendar.current.component(.month, from: g.date)
            if (1...12).contains(month) {
                let group = g.exercise.group  
                var groupsDict = monthlyByGroup[month, default: [:]]
                groupsDict[group, default: 0] += 1
                monthlyByGroup[month] = groupsDict
            }

            gymItems.append(
                HomeItem(
                    id: g.persistentModelID,
                    date: g.date,
                    title: "Gym training",
                    subtitle: details,
                    icon: "dumbbell.fill",
                    kind: .gym
                )
            )
        }

        var monthly: [MonthlyGymCount] = []

        for month in 1...12 {
            let groupsDict = monthlyByGroup[month] ?? [:]

            if groupsDict.isEmpty {
                monthly.append(
                    MonthlyGymCount(
                        month: month,
                        group: .arms,
                        count: 0
                    )
                )
            } else {
                for (group, count) in groupsDict {
                    monthly.append(
                        MonthlyGymCount(
                            month: month,
                            group: group,
                            count: count
                        )
                    )
                }
            }
        }

        monthly.sort {
            if $0.month != $1.month { return $0.month < $1.month }
            return $0.group.rawValue < $1.group.rawValue
        }
        self.monthlyGymCounts = monthly

        // Orden por fecha descendente para la lista
        gymItems.sort { $0.date > $1.date }
        self.items = gymItems
    }

    /// Elimina un entrenamiento de gym y recarga la lista.
    func delete(_ item: HomeItem, in context: ModelContext) {
        if let model = try? context.model(for: item.id) {
            context.delete(model)
            try? context.save()
            load(context: context)
        }
    }

    /// Formatea el peso en kg o lb según preferencias del usuario.
    private func weightString(_ kg: Double, usePounds: Bool) -> String {
        if usePounds {
            let lb = kg * 2.20462
            return String(format: "%.1f lb", lb)
        } else {
            return String(format: "%.1f kg", kg)
        }
    }
}



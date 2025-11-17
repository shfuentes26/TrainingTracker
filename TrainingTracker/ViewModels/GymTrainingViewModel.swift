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

    // Elementos que se muestran en la lista de Gym.
    @Published var items: [HomeItem] = []

    // Carga todos los entrenamientos de gym desde SwiftData.
    func load(context: ModelContext) {
        // Preferencia de unidades de peso
        let usePounds = UserDefaults.standard.bool(forKey: "usePounds")

        // Fetch de entrenamientos de Gym ordenados por fecha descendente
        let gymDesc = FetchDescriptor<GymTraining>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let gyms = (try? context.fetch(gymDesc)) ?? []

        var gymItems: [HomeItem] = []

        for g in gyms {
            let details: String = {
                if let w = g.weightKg {
                    return "\(g.exercise.name) • \(g.reps) reps @ \(weightString(w, usePounds: usePounds))"
                } else {
                    return "\(g.exercise.name) • \(g.reps) reps"
                }
            }()

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

        // Orden por fecha descendente por si acaso
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



//
//  HomeViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/7/25.
//
import SwiftUI
import SwiftData

/// ViewModel de la pantalla Home.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [HomeItem] = []
    
    //TODO: solo para testing
    //@Published var runningGoalSummary: String?
    //@Published var gymGoalSummary: String?

    func load(context: ModelContext) {
        //Preferencias de unidades de medidas
        let useMiles   = UserDefaults.standard.bool(forKey: "useMiles")
        let usePounds  = UserDefaults.standard.bool(forKey: "usePounds")
        
        // Entrenamientos Running
        let runDesc = FetchDescriptor<RunningTraining>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let runs = (try? context.fetch(runDesc)) ?? []

        // Entrenamientos Gym
        let gymDesc = FetchDescriptor<GymTraining>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let gyms = (try? context.fetch(gymDesc)) ?? []

        // variable para guardar elementos de ambos tipos
        var merged: [HomeItem] = []

        for r in runs {
            let distance = distanceString(r.distanceKm, useMiles: useMiles)
            let pace     = paceString(from: r, useMiles: useMiles)
            merged.append(.init(
                id: r.persistentModelID,
                date: r.date,
                title: "Run training",
                subtitle: "\(distance) • \(pace)",
                icon: "figure.run",
                kind: .running
            ))
        }

        for g in gyms {
            let details: String = {
                if let w = g.weightKg {
                    return "\(g.exercise.name) • \(g.reps) reps @ \(weightString(w, usePounds: usePounds))"
                } else {
                    return "\(g.exercise.name) • \(g.reps) reps"
                }
            }()

            merged.append(.init(
                id: g.persistentModelID,
                date: g.date,
                title: "Gym training",
                subtitle: details,
                icon: "dumbbell.fill",
                kind: .gym
            ))
        }
        
        //TODO: solo para testing
        //let summary = GoalsViewModel.currentWeekSummary(context: context)
        //runningGoalSummary = summary.running
        //gymGoalSummary = summary.gym
        
        //print("HomeViewModel. running=\(runningGoalSummary ?? "nil"), gym=\(gymGoalSummary ?? "nil")")

        merged.sort { $0.date > $1.date }
        self.items = merged
    }

    /// Elimina un elemento de la pantalla Home
    func delete(_ item: HomeItem, in context: ModelContext) {
        if let model = try? context.model(for: item.id) {
            context.delete(model)
            try? context.save()
            load(context: context)
        }
    }
    
    /// Convierte kilómetros o millas según preferencia del usuario.
    private func distanceString(_ km: Double, useMiles: Bool) -> String {
        if useMiles {
            let mi = km * 0.621371
            return String(format: "%.1f mi", mi)
        } else {
            return String(format: "%.1f km", km)
        }
    }
    
    /// Normaliza el string de pace del modelo (5:00 min/km o 5:00 min/mi)
    private func paceString(from run: RunningTraining, useMiles: Bool) -> String {
        let paceSecPerKm: Double = {
            guard run.distanceKm > 0 else { return .infinity }
            return Double(run.durationSec) / run.distanceKm
        }()
        guard paceSecPerKm.isFinite else { return "–" }

        if useMiles {
            // Convertimos ritmo por km o ritmo por milla
            let secPerMile = paceSecPerKm / 0.621371
            let m = Int(secPerMile) / 60
            let s = Int(secPerMile) % 60
            return String(format: "%d:%02d min/mi", m, s)
        } else {
            let m = Int(paceSecPerKm) / 60
            let s = Int(paceSecPerKm) % 60
            return String(format: "%d:%02d min/km", m, s)
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

/// Elemento unificado que representa un ítem en la lista de la pantalla Home .
struct HomeItem: Identifiable, Equatable {
    let id: PersistentIdentifier
    let date: Date
    let title: String
    let subtitle: String
    let icon: String
    enum Kind { case running, gym }
    let kind: Kind
}


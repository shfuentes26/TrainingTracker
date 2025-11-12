//
//  HomeViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/7/25.
//
import SwiftUI
import SwiftData

struct HomeItem: Identifiable, Equatable {
    let id: PersistentIdentifier
    let date: Date
    let title: String
    let subtitle: String
    let icon: String
    enum Kind { case running, gym }
    let kind: Kind
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var items: [HomeItem] = []

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
            merged.append(.init(
                id: r.persistentModelID,
                date: r.date,
                title: "Run training",
                subtitle: "\(distanceString(r.distanceKm, useMiles: useMiles)) • \(paceString(r.paceString, useMiles: useMiles))",
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

        // Sort by date desc to intercalar ambas
        merged.sort { $0.date > $1.date }
        self.items = merged
    }

    func delete(_ item: HomeItem, in context: ModelContext) {
        if let model = try? context.model(for: item.id) {
            context.delete(model)
            try? context.save()
            load(context: context)
        }
    }
    
    private func distanceString(_ km: Double, useMiles: Bool) -> String {
        if useMiles {
            let mi = km * 0.621371
            return String(format: "%.1f mi", mi)
        } else {
            return String(format: "%.1f km", km)
        }
    }
    
    private func paceString(_ base: String, useMiles: Bool) -> String {
        var s = base.trimmingCharacters(in: .whitespaces)
        s = s.replacingOccurrences(of: " /", with: "/")
        if useMiles {
            return s.replacingOccurrences(of: "/km", with: " min/mi")
                    .replacingOccurrences(of: "/mi", with: " min/mi")
        } else {
            return s.replacingOccurrences(of: "/mi", with: " min/km")
                    .replacingOccurrences(of: "/km", with: " min/km")
        }
    }
    
    private func weightString(_ kg: Double, usePounds: Bool) -> String {
        if usePounds {
            let lb = kg * 2.20462
            return String(format: "%.1f lb", lb)
        } else {
            return String(format: "%.1f kg", kg)
        }
    }
}


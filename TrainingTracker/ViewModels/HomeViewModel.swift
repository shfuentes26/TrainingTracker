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
        // Entrenamientos Running
        let runDesc = FetchDescriptor<RunningTraining>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let runs = (try? context.fetch(runDesc)) ?? []

        // Entrenamientos Gym
        let gymDesc = FetchDescriptor<GymTraining>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let gyms = (try? context.fetch(gymDesc)) ?? []

        // Map to unified items
        var merged: [HomeItem] = []

        for r in runs {
            merged.append(.init(
                id: r.persistentModelID,
                date: r.date,
                title: "Run training",
                subtitle: "\(distanceString(r.distanceKm)) • \(r.paceString)",
                icon: "figure.run",
                kind: .running
            ))
        }

        for g in gyms {
            let details: String = {
                if let w = g.weightKg {
                    return "\(g.exercise.name) • \(g.reps) reps @ \(weightString(w))"
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
    
    private func distanceString(_ d: Double) -> String {
        String(format: "%.1f km", d)
    }
    private func weightString(_ w: Double) -> String {
        String(format: "%.1f kg", w)
    }
}


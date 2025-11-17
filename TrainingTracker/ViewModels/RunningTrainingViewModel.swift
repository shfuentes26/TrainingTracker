//
//  RunningTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/23/25.
//
import Foundation
import SwiftUI
import SwiftData

/// ViewModel responsable de la Home de trainings
@MainActor
final class RunningTrainingViewModel: ObservableObject {
    // Elementos que se muestran en la lista de Running.
    @Published var items: [HomeItem] = []

    // Carga todos los entrenamientos de running desde SwiftData.
    func load(context: ModelContext) {
        // Preferencia de unidades de distancia
        let useMiles = UserDefaults.standard.bool(forKey: "useMiles")

        // Fetch de entrenamientos de Running ordenados por fecha descendente
        let runDesc = FetchDescriptor<RunningTraining>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let runs = (try? context.fetch(runDesc)) ?? []

        var runningItems: [HomeItem] = []

        for r in runs {
            let distance = distanceString(r.distanceKm, useMiles: useMiles)
            let pace     = paceString(from: r, useMiles: useMiles)

            runningItems.append(
                HomeItem(
                    id: r.persistentModelID,
                    date: r.date,
                    title: "Run training",
                    subtitle: "\(distance) • \(pace)",
                    icon: "figure.run",
                    kind: .running
                )
            )
        }

        // Aseguramos orden por fecha descendente
        runningItems.sort { $0.date > $1.date }
        self.items = runningItems
    }

    // Elimina un entrenamiento de running y recarga la lista.
    func delete(_ item: HomeItem, in context: ModelContext) {
        if let model = try? context.model(for: item.id) {
            context.delete(model)
            try? context.save()
            load(context: context)
        }
    }

    // MARK: - Helpers copiados de HomeViewModel

    // Convierte kilómetros o millas según preferencia del usuario.
    private func distanceString(_ km: Double, useMiles: Bool) -> String {
        if useMiles {
            let mi = km * 0.621371
            return String(format: "%.1f mi", mi)
        } else {
            return String(format: "%.1f km", km)
        }
    }

    // Normaliza el string de pace del modelo (5:00 /km o 5:00 /mi)
    private func paceString(from run: RunningTraining, useMiles: Bool) -> String {
        let paceSecPerKm: Double = {
            guard run.distanceKm > 0 else { return .infinity }
            return Double(run.durationSec) / run.distanceKm
        }()
        guard paceSecPerKm.isFinite else { return "–" }

        if useMiles {
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
}


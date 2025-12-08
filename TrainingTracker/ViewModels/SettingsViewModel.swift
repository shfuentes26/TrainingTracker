//
//  SettingsViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import Foundation
import SwiftData

/// ViewModel encargado de gestionar las preferencias de la app
@MainActor
final class SettingsViewModel: ObservableObject {

    private let kUsePounds = "usePounds"
    private let kUseMiles  = "useMiles"
    
    private let healthManager: HealthKitManager

    /// Variable de peso que se persiste automáticamente en UserDefaults
    @Published var usePounds: Bool {
        didSet { UserDefaults.standard.set(usePounds, forKey: kUsePounds) }
    }
    /// Variable de distancia que se persiste automáticamente en UserDefaults
    @Published var useMiles: Bool {
        didSet { UserDefaults.standard.set(useMiles, forKey: kUseMiles) }
    }

    init(healthManager: HealthKitManager = .shared) {
        self.healthManager = healthManager
        // Valores por defecto en kg y km
        self.usePounds = UserDefaults.standard.object(forKey: kUsePounds) as? Bool ?? false
        self.useMiles  = UserDefaults.standard.object(forKey: kUseMiles)  as? Bool ?? false
    }

    // Etiquetas para mostrar en UI
    var weightUnitLabel: String { usePounds ? "lb" : "kg" }
    var distanceUnitLabel: String { useMiles ? "mi" : "km" }
    
    /// Importa los entrenamientos de carrera desde Health y los guarda en SwiftData.
    func importFromHealth(context: ModelContext) async -> Int {
        do {
            let workouts = try await healthManager.fetchRunningWorkouts()

            guard !workouts.isEmpty else {
                return 0
            }

            var importedCount = 0

            for workout in workouts {
                // Pasamos los valores a constantes simples para que el #Predicate no capture el DTO completo
                let date = workout.date
                let distanceKm = workout.distanceKm
                let durationSec = workout.durationSec

                // Evitamos duplicados con misma fecha + distancia + duración
                let descriptor = FetchDescriptor<RunningTraining>(
                    predicate: #Predicate { training in
                        training.date == date &&
                        training.distanceKm == distanceKm &&
                        training.durationSec == durationSec
                    }
                )

                let existing = try context.fetch(descriptor)
                guard existing.isEmpty else {
                    continue
                }

                let run = RunningTraining(
                    date: date,
                    distanceKm: distanceKm,
                    durationSec: durationSec,
                    notes: "Imported from Apple Health"
                )

                context.insert(run)
                importedCount += 1
            }

            if importedCount > 0 {
                try context.save()
            }

            return importedCount
        } catch {
            print("Error importing from Health: \(error)")
            return 0
        }
    }
}

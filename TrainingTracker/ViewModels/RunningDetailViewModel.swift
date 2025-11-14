//
//  RunningDetailViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

/// ViewModel para mostrar los detalles de un entrenamiento de running.
@MainActor
final class RunningDetailViewModel: ObservableObject {
    @Published var run: RunningTraining?

    private let id: PersistentIdentifier
    init(id: PersistentIdentifier) { self.id = id }

    /// Carga el entrenamiento desde SwiftData usando el identificador.
    func load(context: ModelContext) {
        run = try? context.model(for: id) as? RunningTraining
    }
    
    /// Elimina el entrenamiento cargado.
    @discardableResult
    func delete(context: ModelContext) -> Bool {
        guard let run else { return false }
        context.delete(run)
        do { try context.save(); return true }
        catch { return false }
    }
    
    /// Devuelve la duración del entrenamiento listo para mostrar en la vista
    var formattedDuration: String {
        guard let r = run else { return "—" }
        let seconds = r.durationSec
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        } else {
            return String(format: "%dm %02ds", m, s)
        }
    }
    
    /// Formatea el ritmo según la unidad elegida en Settings
    func formattedPace(useMiles: Bool) -> String {
        guard let r = run else { return "—" }

        let paceSecPerKm: Double = {
            guard r.distanceKm > 0 else { return .infinity }
            return Double(r.durationSec) / r.distanceKm
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
    
    /// Formatea la distancia según la unidad elegida en Settings
    func formattedDistance(useMiles: Bool) -> String {
        guard let r = run else { return "—" }
        if useMiles {
            let mi = r.distanceKm * 0.621371
            return String(format: "%.2f mi", mi)
        } else {
            return String(format: "%.2f km", r.distanceKm)
        }
    }
}


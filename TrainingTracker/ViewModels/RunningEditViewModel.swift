//
//  RunningEditViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

/// ViewModel encargado de editar un entrenamiento de running existente.
@MainActor
final class RunningEditViewModel: ObservableObject {
    @Published var run: RunningTraining?

    // Campos de edición (strings para facilitar teclado/formato)
    @Published var date: Date = .now
    @Published var distanceText: String = ""     // km
    @Published var durationText: String = ""     // h:mm:ss
    @Published var notes: String = ""

    private let id: PersistentIdentifier
    init(id: PersistentIdentifier) { self.id = id }

    /// Carga un entrenamiento desde SwiftData y actualiza los campos del formulario.
    func load(context: ModelContext) {
        guard let r = try? context.model(for: id) as? RunningTraining else { return }
        run = r
        date = r.date
        distanceText = String(format: "%.2f", r.distanceKm)
        durationText = Self.formatHMS(seconds: r.durationSec)
        notes = r.notes ?? ""
    }

    /// Validación general antes de guardar el entrenamiento:
    var canSave: Bool {
        (Double(distanceText.replacingOccurrences(of: ",", with: ".")) ?? -1) > 0 &&
        Self.parseHMS(durationText) != nil
    }

    /// Guarda los cambios realizados en el entrenamiento.
    @discardableResult
    func save(context: ModelContext) -> RunningTraining? {
        guard let r = run else { return nil }
        let newDistance = Double(distanceText.replacingOccurrences(of: ",", with: ".")) ?? r.distanceKm
        let newDuration = Self.parseHMS(durationText) ?? TimeInterval(r.durationSec)

        r.date = date
        r.distanceKm = newDistance
        r.durationSec = Int(newDuration)
        r.notes = notes.isEmpty ? nil : notes

        do { try context.save(); return r } catch { return nil }
    }

    /// Convierte un número de segundos a un formato "H:MM:SS".
    static func formatHMS(seconds: Int) -> String {
            let h = seconds / 3600
            let m = (seconds % 3600) / 60
            let s = seconds % 60
            return String(format: "%d:%02d:%02d", h, m, s)
        }

    /// Convierte un string "H:MM:SS" o "MM:SS" en segundos.
    static func parseHMS(_ text: String) -> TimeInterval? {
        let parts = text.split(separator: ":").map(String.init)
        guard (2...3).contains(parts.count) else { return nil }
        let h = parts.count == 3 ? (Int(parts[0]) ?? 0) : 0
        let m = Int(parts[parts.count - 2]) ?? 0
        let s = Int(parts.last!) ?? 0
        return TimeInterval(h*3600 + m*60 + s)
    }
}


//
//  GymDetailViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

/// ViewModel responsable de gestionar la vista de detalle de un entrenamiento de gimnasio (`GymTraining`).
@MainActor
final class GymDetailViewModel: ObservableObject {
    @Published var session: GymTraining?

    private let id: PersistentIdentifier
    init(id: PersistentIdentifier) { self.id = id }
    
    // Carga el entrenamiento desde SwiftData usando el identificador dado.
    func load(context: ModelContext) {
        session = try? context.model(for: id) as? GymTraining
    }
    
    /// Elimina el entrenamiento actual de la base de datos.
    @discardableResult //elimina warning
    func delete(context: ModelContext) -> Bool {
        guard let session else { return false }
        context.delete(session)
        do { try context.save(); return true }
        catch { return false }
    }
    
    /// Devuelve el peso formateado según preferencia. Devuelve nil si no hay peso.
    func formattedWeight(usePounds: Bool) -> String? {
        guard let w = session?.weightKg else { return nil }
        if usePounds {
            let lb = w * 2.20462
            return String(format: "%.1f lb", lb)
        } else {
            return String(format: "%.1f kg", w)
        }
    }
}


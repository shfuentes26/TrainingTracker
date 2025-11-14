//
//  GymTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/23/25.
//
import Foundation
import SwiftUI
import SwiftData

/// ViewModel responsable de gestionar la lógica del formulario
/// de creación de un entrenamiento de gimnasio
@MainActor
final class GymTrainingViewModel: ObservableObject {

    @Published var date = Date()
    @Published var category: GymGroup = .core
    @Published var selectedExerciseID: UUID?
    @Published var repsText: String = ""
    @Published var weightText: String = ""
    @Published var notes: String = ""

    /// Datos para mostrar una alerta simple a la vista.
    struct AlertData: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    @Published var alert: AlertData?

    /// Indica si el formulario tiene los datos mínimos para guardar un entrenamiento
    var canSave: Bool {
        guard let reps = Int(repsText), reps > 0 else { return false }
        return selectedExerciseID != nil
    }

    /// Guarda un nuevo entrenamiento de gimnasio en SwiftData.
    @discardableResult
    func saveGymTraining(context: ModelContext, exerciseByID: (UUID) -> Exercise?) -> Bool {
        // ejercicio
        guard let id = selectedExerciseID, let exercise = exerciseByID(id) else {
            alert = .init(title: "Select an exercise",
                          message: "Please choose an exercise for \(category.rawValue).")
            return false
        }
        // reps
        guard let reps = Int(repsText), reps > 0 else {
            alert = .init(title: "Add repetitions",
                          message: "Reps must be greater than 0.")
            return false
        }
        // peso
        let weight = parseDouble(weightText)

        let training = GymTraining(
                    exercise: exercise,
                    date: date,
                    reps: reps,
                    weightKg: weight,
                    notes: notes.isEmpty ? nil : notes
                )

        context.insert(training)
        do {
            try context.save()
            return true
        } catch {
            alert = .init(title: "Save failed", message: error.localizedDescription)
            return false
        }
    }

    /// Limpia todos los datos del formulario para empezar un nuevo registro.
    func resetForm() {
        date = Date()
        selectedExerciseID = nil
        repsText = ""
        weightText = ""
        notes = ""
    }

    /// Convierte un texto a Double para el peso para gestionar diferentes formatos
    private func parseDouble(_ text: String) -> Double? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return Double(text.replacingOccurrences(of: ",", with: "."))
    }
}

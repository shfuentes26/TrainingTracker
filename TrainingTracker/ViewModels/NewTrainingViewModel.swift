//
//  NewTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/17/25.
//

import Foundation
import SwiftData


/// ViewModel responsable de la Home de trainings y de gestionar el formulario de creacion de un entrenamiento de running
@MainActor
final class NewTrainingViewModel: ObservableObject {


    @Published var date: Date = .now
    @Published var distanceText: String = ""
    @Published var durationText: String = ""
    @Published var notes: String = ""
    @Published var category: GymGroup = .core
    @Published var selectedExerciseID: UUID?
    @Published var repsText: String = ""
    @Published var weightText: String = ""
    

    @Published var alert: (title: String, message: String)?
    
    /// Indica si el formulario tiene datos suficientes para guardar el entrenamiento
    var canSaveRunning: Bool {
        (parseKm(distanceText) ?? 0) > 0 && (parseHMS(durationText) ?? 0) > 0
    }

    /// Guarda un nuevo entrenamiento de running en SwiftData.
    func save(using context: ModelContext) {
        guard let km = parseKm(distanceText), km > 0 else {
            alert = ("Distance required", "The distance can't be 0")
            return
        }
        guard let secs = parseHMS(durationText), secs > 0 else {
            alert = ("Duration required", "Time is incorrect")
            return
        }
        let obj = RunningTraining(date: date,
                                  distanceKm: km,
                                  durationSec: secs,
                                  notes: notes.isEmpty ? nil : notes)
        context.insert(obj)
        do {
            try context.save()
            reset()
            alert = ("Saved", "Training saved successfully.")
        } catch {
            alert = ("Error", "Training couldn't be saved: \(error.localizedDescription)")
        }
    }
    /// Limpia todos los campos del formulario de running
    func reset() {
        date = .now
        distanceText = ""
        durationText = ""
        notes = ""
    }

    /// Convierte el texto de distancia a Double, aceptando coma o punto.
    private func parseKm(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }

    /// Convierte el texto del tiempo en número total de segundos.
    private func parseHMS(_ text: String) -> Int? {
        let parts = text.split(separator: ":").map { Int($0) ?? 0 }
        guard (1...3).contains(parts.count) else { return nil }
        let (h, m, s): (Int, Int, Int)
        switch parts.count {
        case 3: (h, m, s) = (parts[0], parts[1], parts[2])
        case 2: (h, m, s) = (0, parts[0], parts[1])
        default:(h, m, s) = (0, 0, parts[0])
        }
        return max(0, h*3600 + m*60 + s)
    }
    
    /// Indica si el formulario tiene los datos mínimos para guardar un entrenamiento
    var canSaveGym: Bool {
        guard let reps = Int(repsText), reps > 0 else { return false }
        return selectedExerciseID != nil
    }

    /// Guarda un nuevo entrenamiento de gimnasio en SwiftData.
    @discardableResult
    func saveGymTraining(context: ModelContext, exerciseByID: (UUID) -> Exercise?) -> Bool {
        // ejercicio
        guard let id = selectedExerciseID, let exercise = exerciseByID(id) else {
            alert = (title: "Select an exercise",
                         message: "Please choose an exercise for \(category.rawValue).")
            return false
        }
        // reps
        guard let reps = Int(repsText), reps > 0 else {
            alert = (title: "Add repetitions",
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
            alert = (title: "Saved",
                     message: "Gym training saved successfully.")
            return true
        } catch {
            alert = (title: "Save failed",
                     message: error.localizedDescription)
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





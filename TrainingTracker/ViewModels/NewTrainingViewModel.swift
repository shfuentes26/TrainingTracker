//
//  NewTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/17/25.
//

import Foundation
import SwiftData
import SwiftUI


/// ViewModel responsable de gestionar losl formularios de creacion de un entrenamiento de running y de gym
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
    @Published var allExercises: [Exercise] = []
    
    var filteredExercises: [Exercise] {
        allExercises.filter { $0.group == category }
    }
    
    /// carga los ejercicios de DB
    @MainActor
    func loadExercises(context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Exercise>(
                sortBy: [SortDescriptor(\.name, order: .forward)]
            )
            allExercises = try context.fetch(descriptor)
            //ensureValidSelection()
        } catch {
            print("Error fetching exercises: \(error)")
        }
    }
    
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

    /// Convierte el texto de distancia a Double, aceptando coma o punto y lo convierte a Km si el usuario esta usando millas.
    private func parseKm(_ text: String) -> Double? {
        // Primero convertimos el texto a Double
        guard let value = Double(text.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        // Obtenemos la preferencia del usuario
        let useMiles = UserDefaults.standard.bool(forKey: "useMiles")
        // Convertimos a km si el usuario está en millas
        return useMiles ? (value * 1.60934) : value
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
        guard let exerciseID = selectedExerciseID,
              let exercise = exerciseByID(exerciseID) else {
            alert = (title: "Missing exercise",
                message: "Please select an exercise.")
            return false
            }
        // reps
        guard let reps = Int(repsText), reps > 0 else {
            alert = (title: "Add repetitions",
                message: "Reps must be greater than 0.")
            return false
        }
        //preferencia de peso
        let usePounds = UserDefaults.standard.bool(forKey: "usePounds")

        let training = GymTraining(
                    exercise: exercise,
                    date: date,
                    reps: reps,
                    weightKg: parseKg(weightText, usePounds: usePounds),
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

    /// Limpia todos los datos del formulario para empezar un nuevo registro de gym.
    func resetForm() {
        date = Date()
        selectedExerciseID = nil
        repsText = ""
        weightText = ""
        notes = ""
    }
    
    ///
    func ensureValidSelection() {
        if let id = selectedExerciseID,
           filteredExercises.contains(where: { $0.id == id }) {
            return
        }
        selectedExerciseID = filteredExercises.first?.id
    }
    

    /// Convierte texto del formulario a Double y convierte a kg si el usuario usa libras para guardarlo en SwiftData
    private func parseKg(_ text: String, usePounds: Bool) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard let value = Double(trimmed.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        // Si el usuario está en libras → convertimos a kg
        return usePounds ? (value / 2.20462) : value
    }
}





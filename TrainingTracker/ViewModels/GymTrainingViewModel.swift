//
//  GymTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/23/25.
//
import Foundation
import SwiftUI
import SwiftData

@MainActor
final class GymTrainingViewModel: ObservableObject {

    @Published var date = Date()
    @Published var category: ExerciseCategory = .core
    @Published var selectedExerciseID: UUID?
    @Published var repsText: String = ""
    @Published var weightText: String = ""
    @Published var notes: String = ""

    struct AlertData: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    @Published var alert: AlertData?


    var canSave: Bool {
        guard let reps = Int(repsText), reps > 0 else { return false }
        return selectedExerciseID != nil
    }


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
        // peso (opcional)
        let weight = parseDouble(weightText)

        let session = GymTraining(date: date, notes: notes.isEmpty ? nil : notes)
        let set = ExerciseSet(exercise: exercise,
                              reps: reps,
                              weightKg: weight ?? 0,
                              session: session)
        session.sets.append(set)

        context.insert(session)
        do {
            try context.save()
            return true
        } catch {
            alert = .init(title: "Save failed", message: error.localizedDescription)
            return false
        }
    }

    func resetForm() {
        date = Date()
        selectedExerciseID = nil
        repsText = ""
        weightText = ""
        notes = ""
    }


    private func parseDouble(_ text: String) -> Double? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return Double(text.replacingOccurrences(of: ",", with: "."))
    }
}

//
//  GymEditViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

@MainActor
final class GymEditViewModel: ObservableObject {
    @Published var training: GymTraining?

    @Published var date: Date = .now
    @Published var selectedExerciseID: UUID?
    @Published var repsText: String = ""
    @Published var weightText: String = ""
    @Published var notes: String = ""

    private let id: PersistentIdentifier
    private var usePounds: Bool = false
    
    init(id: PersistentIdentifier) { self.id = id }

    func load(context: ModelContext, usePounds: Bool) {
        self.usePounds = usePounds
        guard let g = try? context.model(for: id) as? GymTraining else { return }
        training = g
        date = g.date
        selectedExerciseID = g.exercise.id
        repsText = String(g.reps)
        if let kg = g.weightKg {
            // convierte el peso según la preferencia
            weightText = formatDisplay(fromKg: kg)
        } else {
            weightText = ""
        }
        notes = g.notes ?? ""
    }

    var canSave: Bool {
        guard let reps = Int(repsText), reps > 0 else { return false }
        return selectedExerciseID != nil
    }

    @discardableResult
    func save(context: ModelContext, exerciseByID: (UUID) -> Exercise?) -> GymTraining? {
        guard let training,
              let id = selectedExerciseID,
              let exercise = exerciseByID(id),
              let reps = Int(repsText), reps > 0
        else { return nil }

        training.date = date
        training.exercise = exercise
        training.reps = reps
        training.weightKg = parseDouble(weightText)
        training.notes = notes.isEmpty ? nil : notes

        do { try context.save(); return training } catch { return nil }
    }
    
    private func formatDisplay(fromKg kg: Double) -> String {
        if usePounds {
            let lb = kg * 2.20462
            return String(format: "%.1f", lb)
        } else {
            return String(format: "%.1f", kg)
        }
    }

    private func parseDouble(_ text: String) -> Double? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.isEmpty == false else { return nil }
        let v = Double(t.replacingOccurrences(of: ",", with: ".")) ?? 0
        return usePounds ? (v / 2.20462) : v
    }
}


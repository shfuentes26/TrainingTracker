//
//  ExercisesViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/19/25.
//

import Foundation
import SwiftData

/// ViewModel responsable de gestionar toda la lógica relacionada con los ejercicios del usuario:
@MainActor
final class ExercisesViewModel: ObservableObject {

    @Published private(set) var exercises: [Exercise] = []
    @Published var nameText: String = ""
    @Published var group: GymGroup = .chestBack
    @Published var usesVariableWeight: Bool = true
    @Published var isShowingForm: Bool = false

    // Controlamos si estamos editando o creando uno nuevo
    private var editingExercise: Exercise?

    ///Carga inicial de ejercicios predefinidos y los de BD
    func load(context: ModelContext) {
        ExercisesPreLoader.initialLoad(context)
        reloadExercises(context: context)
    }

    ///Carga la lista de ejercicios desde DB.
    private func reloadExercises(context: ModelContext) {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\Exercise.name, order: .forward)]
        )
        do {
            exercises = try context.fetch(descriptor)
        } catch {
            print("Error fetching exercises: \(error)")
            exercises = []
        }
    }

    ///Controla el formulario cuando el usuario pulsa en añadir
    func didTapNewExercise() {
        editingExercise = nil
        nameText = ""
        group = .chestBack
        usesVariableWeight = true
        isShowingForm = true
    }
    ///Controla el formulario de edición cuando el usuario pulsa en un ejercicio de la lista
    func didTapEdit(exercise: Exercise) {
        editingExercise = exercise
        nameText = exercise.name
        group = exercise.group
        usesVariableWeight = exercise.usesVariableWeight
        isShowingForm = true
    }
    ///Borra ejercicios
    func delete(at offsets: IndexSet, context: ModelContext) {
        for index in offsets {
            let exercise = exercises[index]
            context.delete(exercise)
        }
        do {
            try context.save()
            reloadExercises(context: context)
        } catch {
            print("Error deleting exercises: \(error)")
        }
    }

    ///Guarda ejercicios
    func save(context: ModelContext) {
        let trimmedName = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        if let exercise = editingExercise {
            // Editar existente
            exercise.name = trimmedName
            exercise.group = group
            exercise.usesVariableWeight = usesVariableWeight
        } else {
            // Crear nuevo
            let new = Exercise(
                name: trimmedName,
                group: group,
                usesVariableWeight: usesVariableWeight
            )
            context.insert(new)
        }

        do {
            try context.save()
            reloadExercises(context: context)
            isShowingForm = false
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
}

//
//  ExercisesViewModelTests.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 12/10/25.
//

import Testing
import SwiftData
import Foundation
@testable import TrainingTracker

@MainActor
struct ExercisesViewModelTests {

    /// Crea un ModelContext en memoria
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self, GymTraining.self, RunningTraining.self,
            configurations: config
        )
        return ModelContext(container)
    }

    /// Helper para crear un ejercicio
    @discardableResult
    private func insertExercise(
        name: String,
        group: GymGroup = .chestBack,
        usesVariableWeight: Bool = true,
        in context: ModelContext
    ) -> Exercise {
        let ex = Exercise(name: name, group: group, usesVariableWeight: usesVariableWeight)
        context.insert(ex)
        return ex
    }


    ///Comprueba que al pulsar “nuevo ejercicio” el VM  limpia el formulario
    @Test
    func didTapNewExerciseResetsFormAndShowsIt() async throws {
        let vm = ExercisesViewModel()

        // Precargamos estado "sucio"
        vm.nameText = "Dirty"
        vm.group = .arms
        vm.usesVariableWeight = false
        vm.isShowingForm = false

        vm.didTapNewExercise()

        #expect(vm.nameText.isEmpty)
        #expect(vm.group == .chestBack)
        #expect(vm.usesVariableWeight == true)
        #expect(vm.isShowingForm == true)
    }

    ///Verifica que al editar un ejercicio existente el VM carga sus valores en el formulario
    @Test
    func didTapEditPopulatesFormAndShowsIt() async throws {
        let context = try makeContext()
        let vm = ExercisesViewModel()

        let ex = insertExercise(
            name: "Bench Press",
            group: .chestBack,
            usesVariableWeight: true,
            in: context
        )

        vm.didTapEdit(exercise: ex)

        #expect(vm.nameText == "Bench Press")
        #expect(vm.group == .chestBack)
        #expect(vm.usesVariableWeight == true)
        #expect(vm.isShowingForm == true)
    }

    ///Asegura que si el nombre está vacío o solo tiene espacios save no crea nada en SwiftData
    @Test
    func saveWithEmptyNameDoesNothing() async throws {
        let context = try makeContext()
        let vm = ExercisesViewModel()

        vm.didTapNewExercise()
        vm.nameText = "   \n  "

        vm.save(context: context)

        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.isEmpty)
    }

    ///Valida el flujo “crear ejercicio” crea un nuevo Exercise con los datos del formulario
    @Test
    func saveCreatesExerciseAndClosesForm() async throws {
        let context = try makeContext()
        let vm = ExercisesViewModel()

        vm.didTapNewExercise()
        vm.nameText = "Squat"
        vm.group = .legs
        vm.usesVariableWeight = true

        vm.save(context: context)

        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.count == 1)

        let saved = try #require(exercises.first)
        #expect(saved.name == "Squat")
        #expect(saved.group == .legs)
        #expect(saved.usesVariableWeight == true)

        // El VM debería haber recargado lista y cerrado formulario
        #expect(vm.exercises.count == 1)
        #expect(vm.isShowingForm == false)
    }

    ///Verificamos que trim funciona antes de guardar
    @Test
    func saveTrimsNameBeforePersisting() async throws {
        let context = try makeContext()
        let vm = ExercisesViewModel()

        vm.didTapNewExercise()
        vm.nameText = "  Deadlift  "
        vm.group = .legs

        vm.save(context: context)

        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        let saved = try #require(exercises.first)
        #expect(saved.name == "Deadlift")
    }

    ///Verifica que tras guardar varios ejercicios el VM recarga la lista y la ordena alfabéticamente por nombre
    @Test
    func saveReloadsExercisesSortedByName() async throws {
        let context = try makeContext()
        let vm = ExercisesViewModel()

        vm.didTapNewExercise()
        vm.nameText = "Zulu"
        vm.save(context: context)

        vm.didTapNewExercise()
        vm.nameText = "Alpha"
        vm.save(context: context)

        // El reload interno usa sort por nombre ascendente
        #expect(vm.exercises.map(\.name) == ["Alpha", "Zulu"])
    }

    ///Valida el flujo “editar ejercicio” no crea un segundo ejercicio y actualiza el existente
    @Test
    func saveWhenEditingUpdatesExistingExercise() async throws {
        let context = try makeContext()
        let vm = ExercisesViewModel()

        // Creamos uno primero usando el propio flujo del VM
        vm.didTapNewExercise()
        vm.nameText = "Bench Press"
        vm.group = .chestBack
        vm.usesVariableWeight = true
        vm.save(context: context)

        #expect(vm.exercises.count == 1)
        let existing = try #require(vm.exercises.first)

        // Entramos en edición
        vm.didTapEdit(exercise: existing)
        vm.nameText = "Bench Press (Barbell)"
        vm.group = .chestBack
        vm.usesVariableWeight = false

        vm.save(context: context)

        // Debe seguir habiendo 1 ejercicio, actualizado
        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.count == 1)

        let updated = try #require(exercises.first)
        #expect(updated.id == existing.id)
        #expect(updated.name == "Bench Press (Barbell)")
        #expect(updated.usesVariableWeight == false)
    }

    ///Comprueba que delete elimina el ejercicio indicado por índice y guarda cambios en SwiftData
    @Test
    func deleteRemovesExercisesAndReloadsList() async throws {
        let context = try makeContext()
        let vm = ExercisesViewModel()

        // Creamos 2 ejercicios a través del VM para poblar `vm.exercises`
        vm.didTapNewExercise()
        vm.nameText = "Alpha"
        vm.save(context: context)

        vm.didTapNewExercise()
        vm.nameText = "Beta"
        vm.save(context: context)

        #expect(vm.exercises.count == 2)

        // Borramos el primero (por índice actual del array)
        vm.delete(at: IndexSet(integer: 0), context: context)

        let remaining = try context.fetch(FetchDescriptor<Exercise>())
        #expect(remaining.count == 1)

        // Y el VM debería reflejarlo tras el reload interno
        #expect(vm.exercises.count == 1)
    }
}

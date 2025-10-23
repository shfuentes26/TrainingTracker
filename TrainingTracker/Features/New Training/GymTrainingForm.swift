//
//  GymTrainingForm.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import Foundation
import SwiftUI
import SwiftData

struct GymTrainingForm: View {
    
    //contexto de la DB
    @Environment(\.modelContext) private var modelContext
    //states del formulario
    @State private var date = Date()
    @State private var category: ExerciseCategory = .core
    @State private var selectedExerciseID: UUID?
    @State private var reps: Int = 0
    @State private var weightKg: Double = 0
    @State private var notes: String = ""
    //states para alertas
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Query(sort: \Exercise.name, order: .forward) private var allExercises: [Exercise]
    private var filteredExercises: [Exercise] {
        allExercises.filter { $0.category == category }
    }
    
    var body: some View {
        Form {
            Section("Gym Details") {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Picker("Category", selection: $category) {
                    ForEach(ExerciseCategory.allCases) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
                .pickerStyle(.segmented)
                if filteredExercises.isEmpty {
                    Text("No exercises for \(category.rawValue).")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Exercise", selection: $selectedExerciseID) {
                        ForEach(filteredExercises, id: \.id) { ex in
                            Text(ex.name).tag(Optional(ex.id))
                        }
                    }
                }
                HStack {
                    Text("Reps")
                    Spacer()
                    TextField("0", value: $reps, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: reps) { _, newValue in
                        }
                }
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("kg", value: $weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text("kg").foregroundStyle(.secondary)
                }
            }
            Section("Notes") {
                TextField("Optional notes…", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            Section {
                Button(action: save) {
                    HStack {
                        Spacer()
                        Label("Save", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .listRowBackground(Color.clear)
            }            
        }
        .onAppear { ensureSelection() }
        .onChange(of: category) { _, _ in ensureSelection() }
        .onChange(of: allExercises) { _, _ in ensureSelection() }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func ensureSelection() {
        if let id = selectedExerciseID,
           filteredExercises.contains(where: { $0.id == id }) {
            return
        }
        selectedExerciseID = filteredExercises.first?.id
    }
    
    private var canSave: Bool {
        selectedExerciseID != nil && reps > 0 && weightKg > 0
    }
    private func save() {
        print("Entramos en save...")
        //validamos que un ejercicio ha sido seleccionado
        guard let id = selectedExerciseID else {
            alertTitle = "Select an exercise"
            alertMessage = "Please choose an exercise for \(category.rawValue)."
            showAlert = true
            return
        }
        //validamos que se han introducido repeticiones
        guard reps > 0 else {
            alertTitle = "Add repetitions"
            alertMessage = "Reps must be greater than 0."
            showAlert = true
            return
        }
        guard
            let id = selectedExerciseID,
            let ex = filteredExercises.first(where: { $0.id == id })
        else { return }
        
        let session = GymTraining(date: date, notes: notes.isEmpty ? nil : notes)
        let set = ExerciseSet(exercise: ex, reps: reps, weightKg: weightKg, session: session)
        session.sets.append(set)
        
        modelContext.insert(session)
        do {
            //guardamos el ejercicio en SwiftData
            try modelContext.save()
                alertTitle = "Training saved succesfully"
                alertMessage = "\(ex.name) • \(reps) reps" + (weightKg > 0 ? " @ \(weightKg) kg" : "")
                showAlert = true
                resetForm()
            } catch {
                print("Error saving training: \(error)")
                alertTitle = "Error"
                alertMessage = "Training could not be saved: \(error.localizedDescription)"
                showAlert = true
            }
    }
    /* funcion para resetear el formulario tras guardar entrenamiento */
    private func resetForm() {
        date = .now
        reps = 0
        weightKg = 0
        notes = ""
        ensureSelection()
        // forzamos a cerrar teclado en caso de estar abierto
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
            
    
}

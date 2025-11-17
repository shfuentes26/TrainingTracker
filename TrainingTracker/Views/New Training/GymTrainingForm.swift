//
//  GymTrainingForm.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import Foundation
import SwiftUI
import SwiftData
/// Formulario para crear un entrenamiento de gimnasio
struct GymTrainingForm: View {
    
    //contexto de la DB
    @Environment(\.modelContext) private var modelContext
    //VM
    @StateObject private var vm = NewTrainingViewModel()
    
    
    
    //states para alertas
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    //preferencia de unidad de peso
    @AppStorage("usePounds") private var usePounds = false
    
    @Query(sort: [SortDescriptor(\Exercise.name, order: .forward)])
    private var allExercises: [Exercise]
    
    private var filteredExercises: [Exercise] {
        allExercises.filter { $0.group == vm.category }
    }
    
    var body: some View {
        Form {
            Section("Gym Details") {
                DatePicker("Date", selection: $vm.date, displayedComponents: .date)
                Picker("Category", selection: $vm.category) {
                    ForEach(GymGroup.allCases, id: \.self) { g in
                        Text(g.rawValue).tag(g)
                    }
                }
                .pickerStyle(.segmented)
                // Lista dinámica de ejercicios según la categoría
                if filteredExercises.isEmpty {
                    Text("No exercises for \(vm.category.rawValue).")
                        .foregroundStyle(.secondary)
                } else {
                    // Para que el Picker funcione con UUID
                    let items: [(UUID, String, Bool)] =
                        filteredExercises.map { ($0.id, $0.name, $0.usesVariableWeight) }

                    Picker("Exercise", selection: $vm.selectedExerciseID) {
                        Text("Select an exercise").tag(nil as UUID?)
                        ForEach(items, id: \.0) { pair in
                            Text(pair.1).tag(pair.0 as UUID?)
                        }
                    }
                }
                
                HStack {
                    Text("Reps")
                    Spacer()
                    TextField("0", text: $vm.repsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField(usePounds ? "lb" : "kg", text: $vm.weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                    Text(usePounds ? "lb" : "kg")
                            .foregroundStyle(.secondary)
                }
            }
            Section("Notes") {
                TextField("Optional notes…", text: $vm.notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            Section {
                Button {
                    let exerciseByID: (UUID) -> Exercise? = { id in
                        allExercises.first(where: { $0.id == id })
                    }

                    let success = vm.saveGymTraining(context: modelContext, exerciseByID: exerciseByID)
                    if success {
                        vm.resetForm()
                    }
                    if let alertData = vm.alert {
                        alertTitle = alertData.title
                        alertMessage = alertData.message
                        showAlert = true
                        vm.alert = nil
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 40, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .listRowBackground(Color.clear)
            }
            
        }
        .onAppear { ensureSelection() }
        .onChange(of: vm.category) { _, _ in ensureSelection() }
        .onChange(of: allExercises) { _, _ in ensureSelection() }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func ensureSelection() {
        if let id = vm.selectedExerciseID,
           filteredExercises.contains(where: { $0.id == id }) {
            return
        }
        vm.selectedExerciseID = filteredExercises.first?.id
    }
}

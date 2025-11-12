//
//  GymEditView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

struct GymEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("usePounds") private var usePounds = false
    
    @StateObject private var vm: GymEditViewModel

    var onSaved: ((GymTraining) -> Void)?


    @Query(sort: [SortDescriptor(\Exercise.name, order: .forward)])
    private var allExercises: [Exercise]

    init(id: PersistentIdentifier, onSaved: ((GymTraining) -> Void)? = nil) {
        _vm = StateObject(wrappedValue: GymEditViewModel(id: id))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Summary") {
                    DatePicker("Date", selection: $vm.date,
                               displayedComponents: [.date, .hourAndMinute])

                    Picker("Exercise", selection: $vm.selectedExerciseID) {
                        Text("Select an exercise").tag(nil as UUID?)
                        ForEach(allExercises, id: \.id) { ex in
                            Text(ex.name).tag(ex.id as UUID?)
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

                    let usesWeight = selectedExercise?.usesVariableWeight ?? true
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField(usesWeight ? (usePounds ? "lb" : "kg") : "—",
                                  text: $vm.weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .disabled(!usesWeight)
                            .opacity(usesWeight ? 1 : 0.4)
                        Text(usePounds ? "lb" : "kg")   
                            .foregroundStyle(.secondary)
                            .opacity(usesWeight ? 1 : 0.4)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes…", text: $vm.notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Edit training")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(!vm.canSave)
                }
            }
            // Carga inicial con la preferencia de peso seleccionada
            .task { vm.load(context: modelContext, usePounds: usePounds) }
            .onChange(of: usePounds) { newValue in
                vm.load(context: modelContext, usePounds: newValue)
            }
        }
    }

    private var selectedExercise: Exercise? {
        if let id = vm.selectedExerciseID {
            return allExercises.first(where: { $0.id == id })
        }
        return nil
    }

    private func save() {
        let lookup: (UUID) -> Exercise? = { id in
            allExercises.first(where: { $0.id == id })
        }
        if let updated = vm.save(context: modelContext, exerciseByID: lookup) {
            onSaved?(updated)
            dismiss()
        }
    }
}


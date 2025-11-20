//
//  ExerciseFormView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/19/25.
//

import SwiftUI
import SwiftData

/// Vista para crear o editar un ejercicio.
struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var vm: ExercisesViewModel


    ///
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise info") {
                    TextField("Name", text: $vm.nameText)

                    Picker("Group", selection: $vm.group) {
                        ForEach(GymGroup.allCases, id: \.self) { g in
                            Text(String(describing: g))
                                .tag(g)
                        }
                    }

                    Toggle("Requires weight", isOn: $vm.usesVariableWeight)
                }
            }
            .navigationTitle("Add exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.save(context: modelContext)
                        dismiss()
                    }
                    .disabled(vm.nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

}

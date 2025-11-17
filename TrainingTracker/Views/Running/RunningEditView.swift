//
//  RunningEditView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

/// Vista para editar un entrenamiento de carrera existente
struct RunningEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: RunningEditViewModel
    
    //preferencia de unidad de distancia
    @AppStorage("useMiles") private var useMiles = false

    var onSaved: ((RunningTraining) -> Void)?

    init(id: PersistentIdentifier, onSaved: ((RunningTraining) -> Void)? = nil) {
        _vm = StateObject(wrappedValue: RunningEditViewModel(id: id))
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Summary") {
                    DatePicker("Date", selection: $vm.date, displayedComponents: [.date, .hourAndMinute])

                    HStack {
                        Text("Distance")
                        Spacer()
                        TextField("0", text: $vm.distanceText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text(useMiles ? "mi" : "km")
                                    .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Duration (h:mm:ss)")
                        Spacer()
                        TextField("0:30:00", text: $vm.durationText)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes…", text: $vm.notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Edit run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }.bold().disabled(!vm.canSave)
                }
            }
            //pasamos la preferencia de distancia al vm
            .task { vm.load(context: modelContext, useMiles: useMiles) }
        }
    }

    private func save() {
        guard let updated = vm.save(context: modelContext) else { return }
        onSaved?(updated)
        dismiss()
    }
}


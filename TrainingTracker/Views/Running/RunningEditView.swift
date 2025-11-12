//
//  RunningEditView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

struct RunningEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: RunningEditViewModel

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
                        Text("Distance (km)")
                        Spacer()
                        TextField("0.00", text: $vm.distanceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
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
            .task { vm.load(context: modelContext) }
        }
    }

    private func save() {
        guard let updated = vm.save(context: modelContext) else { return }
        onSaved?(updated)
        dismiss()
    }
}


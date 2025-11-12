//
//  GymDetailView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

struct GymDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("usePounds") private var usePounds = false
    @State private var showEdit = false
    @StateObject private var vm: GymDetailViewModel

    init(id: PersistentIdentifier) {
        _vm = StateObject(wrappedValue: GymDetailViewModel(id: id))
    }

    var body: some View {
        Group {
            if let s = vm.session {
                List {
                    Section("Summary") {
                        HStack {
                            Text("Exercise:")
                            Spacer()
                            Text(s.exercise.name)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Reps:")
                            Spacer()
                            Text("\(s.reps) reps")
                                .foregroundStyle(.secondary)
                        }
                        if vm.formattedWeight(usePounds: usePounds) != nil {
                            HStack {
                                Text("Weight:")
                                Spacer()
                                Text(vm.formattedWeight(usePounds: usePounds)!)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        HStack {
                            Text("Date:")
                            Spacer()
                            Text(s.date.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("Notes") {
                        Text((s.notes?.isEmpty == false) ? s.notes! : "—")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit")  { showEdit = true }
                Button("Delete", role: .destructive) {
                    if vm.delete(context: modelContext) { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            if let id = vm.session?.persistentModelID {
                GymEditView(id: id) { _ in
                    vm.load(context: modelContext)
                }
            }
        }
        .task { vm.load(context: modelContext) }
    }
}


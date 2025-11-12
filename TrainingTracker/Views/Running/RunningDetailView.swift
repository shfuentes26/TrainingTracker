//
//  RunningDetailView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

struct RunningDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @AppStorage("useMiles") private var useMiles = false
    @StateObject private var vm: RunningDetailViewModel

    init(id: PersistentIdentifier) {
        _vm = StateObject(wrappedValue: RunningDetailViewModel(id: id))
    }

    var body: some View {
        Group {
            if let r = vm.run {
                List {
                    Section("Summary") {
                        HStack {
                            Text("Distance:")
                            Spacer()
                            Text(vm.formattedDistance(useMiles: useMiles))
                                .foregroundStyle(.secondary) 
                        }
                        HStack {
                            Text("Duration:")
                            Spacer()
                            Text(vm.formattedDuration)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Pace:")
                            Spacer()
                            Text(vm.formattedPace(useMiles: useMiles))
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Date:")
                            Spacer()
                            Text(r.date, format: .dateTime.day().month().year().hour().minute())
                                .foregroundStyle(.secondary)
                        }
                    }
                    Section("Notes") {
                        Text((r.notes?.isEmpty == false) ? r.notes! : "—")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    }
                }
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
            if let id = vm.run?.persistentModelID {
                RunningEditView(id: id) { _ in
                    vm.load(context: modelContext)  
                }
            }
        }
        .task { vm.load(context: modelContext) }
    }
}


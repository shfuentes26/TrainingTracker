//
//  SettingsView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUI

///vista de la home de Settings
struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var isImporting = false
    @State private var showImportResult = false
    @State private var importedCount: Int = 0


        var body: some View {
            List {
                Section ("Settings") {
                    Button {
                        Task {
                            isImporting = true
                            let count = await vm.importFromHealth(context: modelContext)
                            importedCount = count
                            isImporting = false
                            showImportResult = true
                        }
                    } label: {
                        HStack {
                            Text("Import from Apple Health")
                            Spacer()
                            if isImporting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isImporting)
                    NavigationLink("Manage exercises") {
                        ExercisesListView()
                    }
                }

                Section {
                    Toggle(isOn: $vm.usePounds) {
                        HStack {
                            Text("Use pounds")
                            Spacer()
                            Text(vm.weightUnitLabel)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Toggle(isOn: $vm.useMiles) {
                        HStack {
                            Text("Use miles")
                            Spacer()
                            Text(vm.distanceUnitLabel)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert(
                "Import completed",
                isPresented: $showImportResult
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                if importedCount > 0 {
                    Text("Imported \(importedCount) running workouts from Apple Health.")
                } else {
                    Text("No new running workouts found to import.")
                }
            }
        }
    }

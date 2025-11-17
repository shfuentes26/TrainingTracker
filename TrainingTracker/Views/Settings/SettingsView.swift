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

        var body: some View {
            List {
                Section ("Settings") {
                    Button("Import from Apple Health") {
                        // TODO: como metemos los entrenamientos de Health??
                    }
                    NavigationLink("Manage exercises") {
                        // TODO: flujo para ver y crear nuevos ejercicios
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
        }
    }

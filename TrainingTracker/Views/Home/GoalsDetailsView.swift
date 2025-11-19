//
//  GoalsView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/18/25.
//

import SwiftUI

///Vista para configurar los goals semanales
struct GoalsDetailsView: View {

    enum Tab {
        case running
        case gym
    }

    @State private var selectedTab: Tab = .running
    @State private var showSaveConfirmation = false
    @State private var saveMessage = ""
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = GoalsViewModel()
    
    private var currentSummary: GoalsViewModel.Summary {
        GoalsViewModel.currentWeekSummary(context: modelContext)
    }

    var body: some View {
        VStack(spacing: 0) {
            //selector en la configuracion
            Picker("Goal type", selection: $selectedTab) {
                Text("Running").tag(Tab.running)
                Text("Gym").tag(Tab.gym)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 12)

            // Contenido de cada pestaña
            ScrollView {
                VStack(spacing: 16) {
                    switch selectedTab {
                    case .running:
                        runningGoalSection
                    case .gym:
                        gymGoalSection
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            
            Section {
                Button(action: {
                    if selectedTab == .running {
                        vm.saveRunningGoal(context: modelContext)
                        saveMessage = "Running goal saved"
                    } else {
                        vm.saveGymGoal(context: modelContext)
                        saveMessage = "Gym goal saved"
                    }
                    showSaveConfirmation = true
                }) {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .listRowBackground(Color.clear)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Goals saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveMessage)
        }
        .onAppear {
            vm.load(context: modelContext)
        }
    }

    ///formulario de running goal
    private var runningGoalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 8) {
                Text("Weekly goal")
                Spacer()
                HStack(spacing: 4) {
                    TextField("0", text: $vm.runningDistanceText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)

                    Text("km")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    ///formulario de gym goal
    private var gymGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            goalRow(title: "Chest/Back", value: $vm.chestBackCount)
            goalRow(title: "Arms", value: $vm.armsCount)
            goalRow(title: "Legs", value: $vm.legsCount)
            goalRow(title: "Core", value: $vm.coreCount)
        }
    }

    ///elemento para mostrar cada objetivo de grupo en el formulario de gym
    private func goalRow(title: String, value: Binding<Int>) -> some View {
        HStack {
            Text("\(title): \(value.wrappedValue)")
            Spacer()
            Stepper(value: value, in: 0...10) {
                Text("\(value.wrappedValue)")
                    .frame(width: 24, alignment: .trailing)
            }
            .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    
}


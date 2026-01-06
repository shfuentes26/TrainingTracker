//
//  TabView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//
import SwiftUI

/// Vista principal de la navigation bar
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .navigationTitle("Inicio")
            }
            .tabItem { Label("tab.home", systemImage: "house.fill") }
        
            NavigationStack {
                GymView()
                    .navigationTitle("Gym")
            }
            .tabItem { Label("tab.gym", systemImage: "dumbbell.fill") }
            NavigationStack {
                NewTrainingView()
                    .navigationTitle("New Training")
            }
            .tabItem { Label("New Training", systemImage: "plus.circle.fill") }

            NavigationStack {
                RunningView()
                    .navigationTitle("Running")
            }
            .tabItem { Label("tab.running", systemImage: "figure.run") }

            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem { Label("tab.settings", systemImage: "gearshape.fill") }
        }
    }
}

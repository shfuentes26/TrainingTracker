//
//  TabView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .navigationTitle("Inicio")
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
        
            NavigationStack {
                GymView()
                    .navigationTitle("Gym")
            }
            .tabItem { Label("Gym", systemImage: "dumbbell.fill") }
            NavigationStack {
                NewTrainingView()
                    .navigationTitle("New Training")
            }
            .tabItem { Label("New Training", systemImage: "plus.circle.fill") }

            NavigationStack {
                RunningView()
                    .navigationTitle("Running")
            }
            .tabItem { Label("Running", systemImage: "figure.run") }

            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

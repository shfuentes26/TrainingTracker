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
            Text("Home")
                .tabItem { Label("Home", systemImage: "house.fill") }

            Text("Gym")
                .tabItem { Label("Gym", systemImage: "dumbbell.fill") }

            Text("New Training")
                .tabItem { Label("New Training", systemImage: "plus.circle.fill") }

            Text("Running")
                .tabItem { Label("Running", systemImage: "figure.run") }

            Text("Settings")
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

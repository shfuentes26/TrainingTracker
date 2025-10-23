//
//  ContentView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        //Tab de navegación principal
        MainTabView()
        //precargamos ejercicios de gym básicos
        .task { ExercisesPreLoader.initialLoad(modelContext) }
    }
}

#Preview {
    ContentView()
}

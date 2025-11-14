//
//  TrainingTrackerApp.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/7/25.
//

import SwiftUI
import SwiftData

///Main
@main
struct TrainingTrackerApp: App {
    
    init() {
        // Configuracion del estilo de la NavigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "MainColor")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        UINavigationBar.appearance().tintColor = .black
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Exercise.self,
                              GymTraining.self,
                              RunningTraining.self])
    }
}

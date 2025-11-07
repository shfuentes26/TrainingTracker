//
//  NewTrainingView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUI
import SwiftData

enum NewTrainingTab: String, CaseIterable, Identifiable {
    case gym = "Gym"
    case running = "Running"
    var id: Self { self }
}

struct NewTrainingView: View {
    @State private var tab: NewTrainingTab = .gym

    var body: some View {
        VStack(spacing: 12) {
            // Cabecera con selector de pestañas internas
            Picker("Tipo", selection: $tab) {
                ForEach(NewTrainingTab.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            // Contenido de cada pestaña
            if tab == .gym {
                    GymTrainingForm()
                } else {
                    RunningTrainingForm()
            }
        }
        .navigationTitle("New Training")
    }
}




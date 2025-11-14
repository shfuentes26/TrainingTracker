//
//  GymView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUICore

///vista de la home de Gym
struct GymView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Gym")
                .font(.title2)
            Text("Contenido de la pestaña Gym")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

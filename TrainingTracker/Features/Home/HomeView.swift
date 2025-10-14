//
//  HomeView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUICore

struct HomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Inicio")
                .font(.title2)
            Text("Contenido de la pestaña Home")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

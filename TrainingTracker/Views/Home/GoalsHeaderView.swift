//
//  GoalsHeaderView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/18/25.
//

import SwiftUI
import SwiftData

/// vista de goals para la Home, muestra el enlace para configurar o el resumen del progreso
struct GoalsHeaderView: View {

    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = GoalsViewModel()

    var body: some View {
        NavigationLink {
            GoalsDetailsView()
        } label: {
            if vm.summary.running != nil || vm.summary.gym != nil {
                // detalle si hay goals
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goals")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let running = vm.summary.running {
                        Text(running)
                            .font(.subheadline)
                    }

                    if let gym = vm.summary.gym {
                        Text(gym)
                            .font(.subheadline)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
            } else {
                // conf warning si no hay goal
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black.opacity(0.75))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create a goal")
                            .font(.headline)

                        Text("Track weekly progress for Running and Gym")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.25))
                )
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, 12)
        .onAppear {
            vm.reloadSummary(context: modelContext)
        }
    }
    
}

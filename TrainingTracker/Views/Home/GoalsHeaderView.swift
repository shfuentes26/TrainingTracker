//
//  GoalsHeaderView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/18/25.
//

import SwiftUI
import SwiftData
import Charts

/// vista de goals para la Home, muestra el enlace para configurar o el resumen del progreso
struct GoalsHeaderView: View {

    @Environment(\.modelContext) private var modelContext
    @ObservedObject var vm: GoalsViewModel

    var body: some View {
        NavigationLink {
            GoalsDetailsView()
        } label: {
            if vm.summary.running != nil || vm.summary.gym != nil {
                // detalle con charts si hay goals
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 24) {
                            if let running = vm.summary.running,
                               running.targetKm > 0 {
                                let progress = max(0, min(running.doneKm / running.targetKm, 1))
                                let percent  = Int((progress * 100).rounded())

                                goalRing(
                                    progress: progress,
                                    title: "Running",
                                    centerText: "\(percent)%",
                                    bottomText: String(
                                        format: "%.1f / %.1f km",
                                        running.doneKm,
                                        running.targetKm
                                    )
                                )
                            }

                            if let gym = vm.summary.gym,
                               gym.totalTarget > 0 {
                                let progress = max(0, min(Double(gym.totalDone) / Double(gym.totalTarget), 1))
                                let percent  = Int((progress * 100).rounded())

                                let bottom = "CB \(gym.chestDone)/\(gym.chestTarget) · " +
                                             "Arms \(gym.armsDone)/\(gym.armsTarget) · " +
                                             "Legs \(gym.legsDone)/\(gym.legsTarget) · " +
                                             "Core \(gym.coreDone)/\(gym.coreTarget)"

                                goalRing(
                                    progress: progress,
                                    title: "Gym",
                                    centerText: "\(percent)%",
                                    bottomText: bottom
                                )
                            }
                        }
                    }
                    //Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
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
    
    /// Donut chart para un goal usando SectorMark
    private func goalRing(
        progress: Double,
            title: String,
                centerText: String,
                    bottomText: String
                        ) -> some View {

        let saveProgress = max(0, min(progress, 1))

        return VStack(spacing: 8) {
            VStack {
                ZStack {
                    Chart {
                        // parte completada en verde
                        SectorMark(
                            angle: .value("Progress", saveProgress),
                            innerRadius: .ratio(0.8),
                            outerRadius: .ratio(1.0)
                        )
                        .foregroundStyle(Color.green)

                        // parte pendiente en rojo suave
                        SectorMark(
                            angle: .value("Remaining", 1 - saveProgress),
                            innerRadius: .ratio(0.8),
                            outerRadius: .ratio(1.0)
                        )
                        .foregroundStyle(Color(.red).opacity(0.25))
                    }
                    .chartLegend(.hidden)
                    .frame(width: 90, height: 90)

                    Text(centerText)
                        .font(.headline)
                }
                .frame(height: 110)
            }

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(bottomText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
}

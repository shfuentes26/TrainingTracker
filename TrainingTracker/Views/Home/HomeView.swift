//
//  HomeView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUI
import SwiftData


struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\GymTraining.date, order: .reverse)])
    private var gymSessions: [GymTraining]
    @Query(sort: [SortDescriptor(\RunningTraining.date, order: .reverse)])
    private var runSessions: [RunningTraining]
    
    var body: some View {
        NavigationStack {
            Group {
                if gymSessions.isEmpty && runSessions.isEmpty {
                    ContentUnavailableView("There are no trainings yet", systemImage: "dumbbell")
                } else {
                    List {
                        if !runSessions.isEmpty {
                            Section("Running") {
                                ForEach(runSessions) { r in
                                    RunningTrainingRow(run: r)
                                }
                                .onDelete(perform: deleteRuns)
                            }
                        }
                        if !gymSessions.isEmpty {
                            Section("Gym") {
                                ForEach(gymSessions) { s in
                                    GymTrainingRow(session: s)
                                }
                                .onDelete(perform: deleteGyms)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Home")
        }
    }
    
    private func deleteGyms(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(gymSessions[index]) }
        try? modelContext.save()
    }
    
    private func deleteRuns(at offsets: IndexSet) {
        for i in offsets { modelContext.delete(runSessions[i]) }
        try? modelContext.save()
    }
    
}

    
    private struct GymTrainingRow: View {
        let session: GymTraining
        
        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                // Fecha
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.date, format: .dateTime.day().month().year())
                        .font(.headline)
                    
                    if let first = session.sets.first {
                        Text("\(first.exercise.name) • \(first.reps) reps @ \(first.weightKg, format: .number) kg")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No sets").foregroundStyle(.tertiary)
                    }
                }
            }
            .contentShape(Rectangle())
            // TODO: navegar al detalle .onTapGesture {}
        }
    }
    
    private struct RunningTrainingRow: View {
        let run: RunningTraining

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(run.date, format: .dateTime.day().month().year())
                        .font(.headline)
                    Text("\(run.distanceKm, format: .number) km • \(run.paceString)")
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        // TODO: navegar al detalle .onTapGesture {}
        }
    }

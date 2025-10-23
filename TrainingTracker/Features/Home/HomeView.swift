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
       private var sessions: [GymTraining]

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "There are no trainings yet",
                        systemImage: "dumbbell")
                } else {
                    List {
                        ForEach(sessions) { s in
                            TrainingRow(session: s)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Home")
        }
    }
    
    private func delete(at offsets: IndexSet) {
            for index in offsets { modelContext.delete(sessions[index]) }
            try? modelContext.save()
        }
}

private struct TrainingRow: View {
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

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
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.items.isEmpty {
                    ContentUnavailableView("There are no trainings yet", systemImage: "dumbbell")
                } else {
                    List {
                        Section {
                            ForEach(vm.items) { item in
                                NavigationLink {
                                    switch item.kind {
                                    case .running:
                                        RunningDetailView(id: item.id)
                                    case .gym:
                                        GymDetailView(id: item.id)
                                    }
                                } label: {
                                    TrainingCardRow(item: item)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                vm.delete(item, in: modelContext)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Home")
            .onAppear { vm.load(context: modelContext) }
        }
    }
}

    
    private struct GymTrainingRow: View {
        let session: GymTraining
        
        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.date, format: .dateTime.day().month().year())
                        .font(.headline)
                    
                    Text(gymSubtitle(session))
                            .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
            // TODO: navegar al detalle .onTapGesture {}
        }
        
        private func gymSubtitle(_ g: GymTraining) -> String {
                if let w = g.weightKg {
                    return "\(g.exercise.name) • \(g.reps) reps @ \(String(format: "%.1f kg", w))"
                } else {
                    return "\(g.exercise.name) • \(g.reps) reps"
                }
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

private struct TrainingCardRow: View {
    let item: HomeItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.date, format: .dateTime.month().day().year())
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .frame(minHeight: 70)
    }
}

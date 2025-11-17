//
//  RunningView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUI


///Vista de la home de Running
struct RunningView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = RunningTrainingViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.items.isEmpty {
                    // Estado vacío con icono de running
                    ContentUnavailableView(
                        "There are no running trainings yet",
                        systemImage: "figure.run"
                    )
                } else {
                    List {
                        Section("Past running trainings") {
                            ForEach(vm.items) { item in
                                NavigationLink {
                                    // Siempre vamos al detalle de running
                                    RunningDetailView(id: item.id)
                                } label: {
                                    RunningTrainingRow(item: item)
                                        .swipeActions(edge: .trailing,
                                                      allowsFullSwipe: true) {
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
            .navigationTitle("Running")
            .onAppear { vm.load(context: modelContext) }
        }
    }
}

/// Fila de la lista de Running
private struct RunningTrainingRow: View {
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


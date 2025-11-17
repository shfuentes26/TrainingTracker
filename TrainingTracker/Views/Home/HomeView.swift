//
//  HomeView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUI
import SwiftData

/// Vista principal que muestra la lista combinada de entrenamientos
struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                //TODO: falta la parte de goals 
                if vm.items.isEmpty {
                    // Vista estándar de iOS para estados vacíos
                    ContentUnavailableView("There are no trainings yet", systemImage: "dumbbell")
                } else {
                    List {
                        Section ("Past trainings") {
                            ForEach(vm.items) { item in
                                // Navegación al detalle según el tipo de entrenamiento
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
                                            // Eliminar el entrenamiento con swipe
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

///vista del entranamiento en la lista combinada
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

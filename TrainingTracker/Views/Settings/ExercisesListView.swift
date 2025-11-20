//
//  ManageExercisesView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/19/25.
//

import SwiftUI
import SwiftData

/// Vista que muestra la lista de ejercicios.
struct ExercisesListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = ExercisesViewModel()

    @State private var showingForm = false
    @State private var selectedExercise: Exercise?

    var body: some View {
        List {
            Section("Exercises") {
                if vm.exercises.isEmpty {
                    Text("No exercises yet. Add your first one with the + button.")
                        .foregroundStyle(.secondary)
                } else {
                    // Lista de ejercicios
                    ForEach(vm.exercises, id: \.id) { exercise in
                        Button {
                            vm.didTapEdit(exercise: exercise)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.body)
                                    
                                    // Nombre del grupo muscular
                                    Text(String(describing: exercise.group))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        vm.delete(at: offsets, context: modelContext)
                    }
                }
            }
        }
        .navigationTitle("Manage exercises")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.didTapNewExercise()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            vm.load(context: modelContext)
        }
        .sheet(isPresented: $vm.isShowingForm) {
            ExerciseDetailView(vm: vm)
        }
    }

   
}

//
//  GymView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUI
import Charts

///vista de la home de Gym
struct GymView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = GymTrainingViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.items.isEmpty {
                    // Estado vacío para gym
                    ContentUnavailableView(
                        "There are no gym trainings yet",
                        systemImage: "dumbbell"
                    )
                } else {
                    List {
                        // Gráfico
                        if !vm.availableYears.isEmpty {
                            Section {
                                YearlyMonthlyGymPager(
                                    years: vm.availableYears,
                                    selectedYear: $vm.selectedYear,
                                    countsProvider: { year in
                                        vm.monthlyGymCounts(for: year)
                                    }
                                )
                                .frame(height: 230)
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            } header: {
                                HStack {
                                    Text("Monthly gym trainings")
                                    Spacer()
                                    Text(verbatim: "\(vm.selectedYear)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary.opacity(0.85))
                                }
                            }
                        }

                        // Listado de trainings
                        Section("Past gym trainings") {
                            ForEach(vm.items) { item in
                                NavigationLink {
                                    GymDetailView(id: item.id)
                                } label: {
                                    GymTrainingRow(item: item)
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
            .navigationTitle("Gym")
            .onAppear { vm.load(context: modelContext) }
        }
    }
}

/// Pager con swipe entre años para mostrar el chart mensual de gym
private struct YearlyMonthlyGymPager: View {
    let years: [Int]
    @Binding var selectedYear: Int
    let countsProvider: (Int) -> [GymTrainingViewModel.MonthlyGymCount]

    var body: some View {
        TabView(selection: $selectedYear) {
            ForEach(years, id: \.self) { year in
                YearlyMonthlyGymChart(
                    year: year,
                    counts: countsProvider(year)
                )
                .tag(year)
                .padding(.horizontal, 4)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

/// Chart mensual para un año concreto con desglose por grupo
private struct YearlyMonthlyGymChart: View {
    let year: Int
    let counts: [GymTrainingViewModel.MonthlyGymCount]

    var body: some View {
        Chart(counts) { entry in
            let symbols = Calendar.current.shortMonthSymbols
            let label = symbols.indices.contains(entry.month - 1)
                ? symbols[entry.month - 1]
                : "\(entry.month)"

            BarMark(
                x: .value("Month", label),
                y: .value("Sessions", entry.count)
            )
            .foregroundStyle(
                by: .value("Group", String(describing: entry.group))
            )
        }
        .frame(height: 200)
        .chartYAxisLabel { Text("Sessions") }
        .chartLegend(position: .bottom)
        .accessibilityLabel("Monthly gym trainings chart for \(year)")
    }
}


/// Fila para la lista de Gym
private struct GymTrainingRow: View {
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


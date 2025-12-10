//
//  RunningView.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/14/25.
//

import SwiftUI
import Charts


///Vista de la home de Running
struct RunningView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = RunningTrainingViewModel()
    @AppStorage("useMiles") private var useMiles: Bool = false

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
                        // Graafico
                        if !vm.availableYears.isEmpty {
                            Section {
                                YearlyMonthlyDistancePager(
                                    years: vm.availableYears,
                                    selectedYear: $vm.selectedYear,
                                    useMiles: useMiles,
                                    distancesProvider: { year in
                                        vm.monthlyDistances(for: year)
                                    }
                                )
                                .frame(height: 230)
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                            } header: {
                                HStack {
                                    Text("Monthly distance")
                                    Spacer()
                                    Text(verbatim: "\(vm.selectedYear)")
                                        .font(.subheadline)
                                        .foregroundStyle(.primary.opacity(0.75))
                                }
                            }
                        }

                        // Lista de runnings
                        Section("Past running trainings") {
                            ForEach(vm.items) { item in
                                NavigationLink {
                                    // vamos al detalle de running
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

/// Pager con swipe entre años para mostrar el chart mensual
private struct YearlyMonthlyDistancePager: View {
    let years: [Int]
    @Binding var selectedYear: Int
    let useMiles: Bool
    let distancesProvider: (Int) -> [RunningTrainingViewModel.MonthlyRunningDistance]

    var body: some View {
        TabView(selection: $selectedYear) {
            ForEach(years, id: \.self) { year in
                YearlyMonthlyDistanceChart(
                    year: year,
                    distances: distancesProvider(year),
                    useMiles: useMiles
                )
                .tag(year)
                .padding(.horizontal, 4)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

/// Chart mensual para un año concreto
private struct YearlyMonthlyDistanceChart: View {
    let year: Int
    let distances: [RunningTrainingViewModel.MonthlyRunningDistance]
    let useMiles: Bool

    var body: some View {
        Chart(distances) { entry in
            let symbols = Calendar.current.shortMonthSymbols
            let label = symbols.indices.contains(entry.month - 1)
            ? symbols[entry.month - 1]
            : "\(entry.month)"

            let distance = useMiles
            ? entry.totalKm * 0.621371
            : entry.totalKm

            BarMark(
                x: .value("Month", label),
                y: .value("Distance", distance)
            )
        }
        .frame(height: 200)
        .chartYAxisLabel {
            Text("Distance (\(useMiles ? "mi" : "km"))")
        }
        .accessibilityLabel("Monthly distance chart for \(year)")
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


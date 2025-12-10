//
//  RunningTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/23/25.
//
import Foundation
import SwiftUI
import SwiftData

/// ViewModel responsable de la Home de trainings
@MainActor
final class RunningTrainingViewModel: ObservableObject {
    // Elementos que se muestran en la lista de Running.
    @Published var items: [HomeItem] = []
    @Published var monthlyDistances: [MonthlyRunningDistance] = []
    
    // Control de años del gráfico
    @Published var selectedYear: Int
    @Published var availableYears: [Int] = []
    
    // Cache interna de runs para calcular charts por año sin refetch constante
    private var allRuns: [RunningTraining] = []
    
    //objeto para preparar data para el chart
    struct MonthlyRunningDistance: Identifiable {
        let id = UUID()
        let month: Int
        let totalKm: Double
    }
    
    init() {
        self.selectedYear = Calendar.current.component(.year, from: Date())
    }

    // Carga todos los entrenamientos de running desde SwiftData.
    func load(context: ModelContext) {
        // Preferencia de unidades de distancia
        let useMiles = UserDefaults.standard.bool(forKey: "useMiles")
        
        // Fetch de entrenamientos de Running ordenados por fecha descendente
        let runDesc = FetchDescriptor<RunningTraining>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let runs = (try? context.fetch(runDesc)) ?? []
        self.allRuns = runs
        
        // Construimos items de lista (como antes)
        var runningItems: [HomeItem] = []
        for r in runs {
            let distance = distanceString(r.distanceKm, useMiles: useMiles)
            let pace     = paceString(from: r, useMiles: useMiles)
            
            runningItems.append(
                HomeItem(
                    id: r.persistentModelID,
                    date: r.date,
                    title: "Run training",
                    subtitle: "\(distance) • \(pace)",
                    icon: "figure.run",
                    kind: .running
                )
            )
        }
        
        runningItems.sort { $0.date > $1.date }
        self.items = runningItems
        
        // Años disponibles para el gráfico
        let currentYear = Calendar.current.component(.year, from: Date())
        var years = Set(runs.map { Calendar.current.component(.year, from: $0.date) })
        years.insert(currentYear)
        
        self.availableYears = years.sorted()
        
        // Si el año seleccionado ya no existe (caso raro), volvemos al actual
        if !availableYears.contains(selectedYear) {
            selectedYear = currentYear
        }
    }
    
    /// Distancias mensuales para un año concreto (filtra por año).
    func monthlyDistances(for year: Int) -> [MonthlyRunningDistance] {
        var monthlyTotals = Array(repeating: 0.0, count: 12)

        for r in allRuns {
            let rYear = Calendar.current.component(.year, from: r.date)
            guard rYear == year else { continue }

            let month = Calendar.current.component(.month, from: r.date)
            if (1...12).contains(month) {
                monthlyTotals[month - 1] += r.distanceKm
            }
        }

        return monthlyTotals.enumerated().map { index, km in
            MonthlyRunningDistance(month: index + 1, totalKm: km)
        }
    }
    
    
    /// Convierte kilómetros o millas según preferencia del usuario.
    private func distanceString(_ km: Double, useMiles: Bool) -> String {
        if useMiles {
            let mi = km * 0.621371
            return String(format: "%.1f mi", mi)
        } else {
            return String(format: "%.1f km", km)
        }
    }
    
    /// Elimina un entrenamiento de running y recarga la lista.
    func delete(_ item: HomeItem, in context: ModelContext) {
        if let model = try? context.model(for: item.id) {
            context.delete(model)
            try? context.save()
            load(context: context)
        }
    }

    /// Normaliza el string de pace del modelo (5:00 /km o 5:00 /mi)
    private func paceString(from run: RunningTraining, useMiles: Bool) -> String {
        let paceSecPerKm: Double = {
            guard run.distanceKm > 0 else { return .infinity }
            return Double(run.durationSec) / run.distanceKm
        }()
        guard paceSecPerKm.isFinite else { return "–" }

        if useMiles {
            let secPerMile = paceSecPerKm / 0.621371
            let m = Int(secPerMile) / 60
            let s = Int(secPerMile) % 60
            return String(format: "%d:%02d min/mi", m, s)
        } else {
            let m = Int(paceSecPerKm) / 60
            let s = Int(paceSecPerKm) % 60
            return String(format: "%d:%02d min/km", m, s)
        }
    }
}


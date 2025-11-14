//
//  SettingsViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import Foundation

/// ViewModel encargado de gestionar las preferencias de la app
@MainActor
final class SettingsViewModel: ObservableObject {

    private let kUsePounds = "usePounds"
    private let kUseMiles  = "useMiles"

    /// Variable de peso que se persiste automáticamente en UserDefaults
    @Published var usePounds: Bool {
        didSet { UserDefaults.standard.set(usePounds, forKey: kUsePounds) }
    }
    /// Variable de distancia que se persiste automáticamente en UserDefaults
    @Published var useMiles: Bool {
        didSet { UserDefaults.standard.set(useMiles, forKey: kUseMiles) }
    }

    init() {
        // Valores por defecto en kg y km
        self.usePounds = UserDefaults.standard.object(forKey: kUsePounds) as? Bool ?? false
        self.useMiles  = UserDefaults.standard.object(forKey: kUseMiles)  as? Bool ?? false
    }

    // Etiquetas para mostrar en UI
    var weightUnitLabel: String { usePounds ? "lb" : "kg" }
    var distanceUnitLabel: String { useMiles ? "mi" : "km" }
}

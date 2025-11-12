//
//  SettingsViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {

    private let kUsePounds = "usePounds"
    private let kUseMiles  = "useMiles"

    @Published var usePounds: Bool {
        didSet { UserDefaults.standard.set(usePounds, forKey: kUsePounds) }
    }

    @Published var useMiles: Bool {
        didSet { UserDefaults.standard.set(useMiles, forKey: kUseMiles) }
    }

    init() {
        // Valores por defecto en kg y km
        self.usePounds = UserDefaults.standard.object(forKey: kUsePounds) as? Bool ?? false
        self.useMiles  = UserDefaults.standard.object(forKey: kUseMiles)  as? Bool ?? false
    }

    // Ayudas rápidas para el resto de la app
    var weightUnitLabel: String { usePounds ? "lb" : "kg" }
    var distanceUnitLabel: String { useMiles ? "mi" : "km" }
}

//
//  SettingsViewModelTests.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/14/25.
//

import Testing
import Foundation
@testable import TrainingTracker


@MainActor
struct SettingsViewModelTests {

    /// Verifica los valores por defecto del SettingsViewModel cuando no existen preferencias previas guardadas en UserDefaults
    @Test
    func defaultValuesAreKgAndKm() async throws {
        let defaults = UserDefaults.standard
        // Limpiamos los valores antes del test
        defaults.removeObject(forKey: "usePounds")
        defaults.removeObject(forKey: "useMiles")

        let vm = SettingsViewModel()

        #expect(vm.usePounds == false)
        #expect(vm.useMiles == false)
        #expect(vm.weightUnitLabel == "kg")
        #expect(vm.distanceUnitLabel == "km")
    }
    /// Verifica que cambiar los toggles de unidades en el ViewModel se actualiza el estado interno del VM y persiste correctamente en UserDefaults
    @Test
    func togglingUnitsDefaults() async throws {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "usePounds")
        defaults.set(false, forKey: "useMiles")

        let vm = SettingsViewModel()

        #expect(vm.usePounds == false)
        #expect(vm.useMiles == false)

        // Cambiamos las preferencias
        vm.usePounds = true
        vm.useMiles = true

        // Comprobamos persistencia y etiquetas
        #expect(defaults.bool(forKey: "usePounds") == true)
        #expect(defaults.bool(forKey: "useMiles") == true)
        #expect(vm.weightUnitLabel == "lb")
        #expect(vm.distanceUnitLabel == "mi")
    }
}

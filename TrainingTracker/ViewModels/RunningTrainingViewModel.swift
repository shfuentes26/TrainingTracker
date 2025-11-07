//
//  RunningTrainingViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/23/25.
//
import Foundation
import SwiftUI
import SwiftData

@MainActor
final class RunningTrainingViewModel: ObservableObject {


    @Published var date: Date = .now
    @Published var distanceText: String = ""
    @Published var durationText: String = ""  
    @Published var notes: String = ""

    @Published var alert: (title: String, message: String)?

    var canSave: Bool {
        (parseKm(distanceText) ?? 0) > 0 && (parseHMS(durationText) ?? 0) > 0
    }


    func save(using context: ModelContext) {
        guard let km = parseKm(distanceText), km > 0 else {
            alert = ("Distance required", "The distance can't be 0")
            return
        }
        guard let secs = parseHMS(durationText), secs > 0 else {
            alert = ("Duration required", "Format required h:mm:ss (ej. 0:45:30).")
            return
        }
        let obj = RunningTraining(date: date,
                                  distanceKm: km,
                                  durationSec: secs,
                                  notes: notes.isEmpty ? nil : notes)
        context.insert(obj)
        do {
            try context.save()
            reset()
            alert = ("Saved", "Training saved successfully.")
        } catch {
            alert = ("Error", "Training couldn't be saved: \(error.localizedDescription)")
        }
    }

    func reset() {
        date = .now
        distanceText = ""
        durationText = ""
        notes = ""
    }

    // MARK: - Helpers de formato/parseo

    func applyDurationMask(_ raw: String) -> String {
        let digits = raw.filter { $0.isNumber }
        var out = ""
        let c = Array(digits)
        if c.count > 0 { out.append(c[0]) }                  // h
        if c.count > 1 { out.append(":"); out.append(c[1]) } // m
        if c.count > 2 { out.append(c[2]) }                  // m
        if c.count > 3 { out.append(":"); out.append(c[3]) } // s
        if c.count > 4 { out.append(c[4]) }                  // s
        if c.count > 5 { out.append(c[5]) }                  // s
        return String(out.prefix(8))
    }

    private func parseKm(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }

    private func parseHMS(_ text: String) -> Int? {
        let parts = text.split(separator: ":").map { Int($0) ?? 0 }
        guard (1...3).contains(parts.count) else { return nil }
        let (h, m, s): (Int, Int, Int)
        switch parts.count {
        case 3: (h, m, s) = (parts[0], parts[1], parts[2])
        case 2: (h, m, s) = (0, parts[0], parts[1])
        default:(h, m, s) = (0, 0, parts[0])
        }
        return max(0, h*3600 + m*60 + s)
    }
}

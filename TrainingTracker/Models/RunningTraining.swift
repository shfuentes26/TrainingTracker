//
//  RunningTraining.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 10/23/25.
//
import Foundation
import SwiftData

@Model
final class RunningTraining {
    @Attribute(.unique) var id: UUID
    var date: Date
    var distanceKm: Double
    var durationSec: Int
    var notes: String?

    init(date: Date, distanceKm: Double, durationSec: Int, notes: String?) {
        self.id = UUID()
        self.date = date
        self.distanceKm = distanceKm
        self.durationSec = durationSec
        self.notes = notes
    }

    // Derivados útiles
    var paceSecPerKm: Double { distanceKm > 0 ? Double(durationSec) / distanceKm : .infinity }
    var paceString: String {
        guard paceSecPerKm.isFinite else { return "–" }
        let s = Int(paceSecPerKm.rounded())
        return String(format: "%d:%02d /km", s/60, s%60)
    }
}

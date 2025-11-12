//
//  RunningDetailViewModel.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 11/10/25.
//
import SwiftUI
import SwiftData

@MainActor
final class RunningDetailViewModel: ObservableObject {
    @Published var run: RunningTraining?

    private let id: PersistentIdentifier
    init(id: PersistentIdentifier) { self.id = id }

    func load(context: ModelContext) {
        run = try? context.model(for: id) as? RunningTraining
    }
    
    @discardableResult
    func delete(context: ModelContext) -> Bool {
        guard let run else { return false }
        context.delete(run)
        do { try context.save(); return true }
        catch { return false }
    }
    
    var formattedDuration: String {
        guard let r = run else { return "—" }
        let seconds = r.durationSec
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        } else {
            return String(format: "%dm %02ds", m, s)
        }
    }
    
    func formattedPace(useMiles: Bool) -> String {
        guard let r = run else { return "—" }
        let base = r.paceString
            .replacingOccurrences(of: " /km", with: "/km")
            .replacingOccurrences(of: " /mi", with: "/mi")
        if useMiles {
            if base.contains("/mi") { return base.replacingOccurrences(of: "/mi", with: " min/mi") }
            return base.replacingOccurrences(of: "/km", with: " min/mi")
        } else {
            if base.contains("/km") { return base.replacingOccurrences(of: "/km", with: " min/km") }
            return base.replacingOccurrences(of: "/mi", with: " min/km")
        }
    }
    
    func formattedDistance(useMiles: Bool) -> String {
        guard let r = run else { return "—" }
        if useMiles {
            let mi = r.distanceKm * 0.621371
            return String(format: "%.2f mi", mi)
        } else {
            return String(format: "%.2f km", r.distanceKm)
        }
    }
}


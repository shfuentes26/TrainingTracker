//
//  HealthKitManager.swift
//  TrainingTracker
//
//  Created by Satur Hernandez Fuentes on 12/3/25.
//

import Foundation
import HealthKit

/// Errores del flujo de HealthKit
enum HealthKitError: Error {
    case notAvailableOnDevice
    case notAuthorized
}

/// DTO  para no acoplar HealthKit con SwiftData
struct RunningWorkoutDTO {
    let date: Date
    let distanceKm: Double
    let durationSec: Int
}

/// Manager que encapsula la lógica de Apple Health
final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    private init() {}

    private func requestAuthorizationIfNeeded() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available on this device")
            throw HealthKitError.notAvailableOnDevice
        }

        let workoutType = HKObjectType.workoutType()
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!

        let typesToShare: Set<HKSampleType> = [workoutType, distanceType]
        let typesToRead: Set<HKObjectType> = [workoutType, distanceType]

     
        try await healthStore.requestAuthorization(
            toShare: typesToShare,
            read: typesToRead
        )

        print("requestAuthorization finished (read access requested)")
    }

    /// Devuelve todos los entrenamientos de tipo running de Apple Health
    func fetchRunningWorkouts() async throws -> [RunningWorkoutDTO] {
        print("Starting fetchRunningWorkouts()")
        try await requestAuthorizationIfNeeded()
        print("Authorization finished")

        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        print("HKWorkoutActivityType.running predicate")
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        ]

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: sortDescriptors
            ) { _, samples, error in
                if let error = error {
                    print("Query error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    print("No workouts found")
                    continuation.resume(returning: [])
                    return
                }
                
                print("workouts returned by HealthKit: \(workouts.count)")

                let meterUnit = HKUnit.meter()
                let results: [RunningWorkoutDTO] = workouts.map { workout in
                    let distanceMeters = workout.totalDistance?.doubleValue(for: meterUnit) ?? 0
                    let distanceKm = distanceMeters / 1000.0
                    let durationSec = Int(workout.duration)
                    
                    print("Workout: date=\(workout.startDate), distance=\(distanceKm) km, duration=\(durationSec) sec")


                    return RunningWorkoutDTO(
                        date: workout.startDate,
                        distanceKm: distanceKm,
                        durationSec: durationSec
                    )
                }

                continuation.resume(returning: results)
            }

            self.healthStore.execute(query)
        }
    }
    
    /// Guarda un entrenamiento de carrera en Apple Health a partir de un RunningTraining.
    func saveRunningWorkout(from training: RunningTraining) async throws {
        try await requestAuthorizationIfNeeded()

        let distanceMeters = training.distanceKm * 1000.0
        let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: distanceMeters)

        let startDate = training.date
        let endDate = training.date.addingTimeInterval(TimeInterval(training.durationSec))

        let workout = HKWorkout(
            activityType: .running,
            start: startDate,
            end: endDate,
            workoutEvents: nil,
            totalEnergyBurned: nil,
            totalDistance: distanceQuantity,
            metadata: [
                "sourceApp" : "TrainingTracker",
                "notes"     : training.notes ?? ""
            ]
        )

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            healthStore.save(workout) { success, error in
                if let error = error {
                    print("Error saving workout to HealthKit: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    print("Saved workout to HealthKit: success=\(success)")
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

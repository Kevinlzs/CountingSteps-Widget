//
//  StepDataManager.swift
//  CountingSteps-Widget
//
//  Created by Andy Hernandez on 4/20/25.
//
import SwiftUI
import HealthKit

class StepDataManager: ObservableObject {
    @Published var stepCount = 0
    @Published var isAuthorized = false
    @Published var selectedTimeframe = 0
    
    static let shared = StepDataManager()
    
    private let healthStore = HKHealthStore()
    private let timeframes = ["Day", "Week", "Month"]
    
    private init() {
        setupHealthKit()
    }
    
    var timeframeText: String {
        return timeframes[selectedTimeframe]
    }
    
    func setupHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
            healthStore.getRequestStatusForAuthorization(toShare: [], read: [stepCountType]) { (status, error) in
                DispatchQueue.main.async {
                    if status == .unnecessary {
                        self.isAuthorized = true
                        self.fetchStepCount()
                    }
                }
            }
        }
    }
    
    func requestAuthorization() {
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(toShare: [], read: [stepCountType]) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.isAuthorized = true
                    self.fetchStepCount()
                } else {
                    print("Authorization failed: \(String(describing: error))")
                }
            }
        }
    }
    
    func fetchStepCount() {
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        
        let startDate: Date
        
        switch selectedTimeframe {
        case 0:
            startDate = Calendar.current.startOfDay(for: now)
        case 1:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        case 2:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        default:
            startDate = Calendar.current.startOfDay(for: now)
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    self.stepCount = 0
                    print("Failed to fetch steps: \(String(describing: error))")
                    return
                }

                self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }

        healthStore.execute(query)
    }
    
    func changeTimeframe(to index: Int) {
        selectedTimeframe = index
        fetchStepCount()
    }
}

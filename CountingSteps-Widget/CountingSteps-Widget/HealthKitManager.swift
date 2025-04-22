//
//  HealthKitManager.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/17/25.
//

import HealthKit
import FirebaseFirestore
import FirebaseAuth

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private let db = Firestore.firestore()

    @Published var steps: Double = 0
    @Published var distance: Double = 0
    @Published var calories: Double = 0
    @Published var stepGoal: Int = 10000 // Default fallback
    
    func requestAuthorization() {
        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                let (start, end) = self.getDateRange(for: "Day")
                self.fetchHealthData(from: start, to: end)
                self.fetchStepGoal()
            } else {
                print("HealthKit Auth failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func uploadDailyHealthData() {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User not logged in")
//            return
//        }
        let userId = "tNX6PyVBIPd6vF143q9Dk5Dfqk53";
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: Date()) // "2025-04-15"
        let documentId = "\(userId)_\(dateKey)"

        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "M/dd/yy"

        let data: [String: Any] = [
            "uid": userId,
            "date": displayDateFormatter.string(from: Date()), // "4/15/25"
            "stepCount": Int(steps),
            "distance": distance,
            "caloriesBurnt": calories,
            "lastUpdated": Timestamp(date: Date())
        ]

        db.collection("stepRecords")
            .document(documentId)
            .setData(data) { error in
                if let error = error {
                    print("Error uploading step record: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded step record for \(dateKey)")
                }
            }
    }

    func fetchStepGoal() {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User not logged in")
//            return
//        }
        let userId = "tNX6PyVBIPd6vF143q9Dk5Dfqk53";
        db.collection("users").document(userId).getDocument { document, error in
            if let doc = document, doc.exists, let data = doc.data() {
                self.stepGoal = data["stepGoal"] as? Int ?? 10000
            } else {
                print("Failed to fetch stepGoal: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func fetchHealthData(from startDate: Date, to endDate: Date) {
        let group = DispatchGroup()

        group.enter()
        fetchQuantity(.stepCount, from: startDate, to: endDate) { value in
            self.steps = value
            group.leave()
        }

        group.enter()
        fetchQuantity(.distanceWalkingRunning, from: startDate, to: endDate) { value in
            self.distance = value
            group.leave()
        }

        group.enter()
        fetchQuantity(.activeEnergyBurned, from: startDate, to: endDate) { value in
            self.calories = value
            group.leave()
        }

        group.notify(queue: .main) {
            self.uploadHealthData(for: startDate)
        }
    }
    
    func uploadHealthData(for date: Date) {
        let userId = "tNX6PyVBIPd6vF143q9Dk5Dfqk53";
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: date)

        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "M/dd/yy"

        let data: [String: Any] = [
            "uid": userId,
            "date": displayDateFormatter.string(from: date),
            "stepCount": Int(steps),
            "distance": distance,
            "caloriesBurnt": calories,
            "lastUpdated": Timestamp(date: Date())
        ]

        db.collection("stepRecords")
            .document("\(userId)_\(dateKey)")
            .setData(data) { error in
                if let error = error {
                    print("Error uploading step record: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded step record for \(dateKey)")
                }
            }
    }
    
    func getDateRange(for selection: String) -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()

        switch selection {
        case "Day":
            let start = calendar.startOfDay(for: now)
            return (start, now)

        case "Week":
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return (start, now)

        case "Month":
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return (start, now)

        default:
            let start = calendar.startOfDay(for: now)
            return (start, now)
        }
    }
    
    func fetchAndUploadData(for range: String) {
        let (start, end) = getDateRange(for: range)
        fetchHealthData(from: start, to: end)
    }

    private func fetchQuantity(_ id: HKQuantityTypeIdentifier, from: Date, to: Date, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: id) else {
            completion(0)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: quantityType,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                let unit: HKUnit
                switch id {
                    case .stepCount: unit = .count()
                    case .distanceWalkingRunning: unit = .mile()
                    case .activeEnergyBurned: unit = .kilocalorie()
                    default: unit = .count()
                }

                let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                completion(value)
            }
        }

        healthStore.execute(query)
    }
}

//
//  LeaderboardService.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/23/25.
//

import Foundation
import FirebaseFirestore

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let steps: Int
}

enum LeaderboardRange: String {
    case day, week, month
}

struct LeaderboardService {

    static func dateRange(for range: LeaderboardRange) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        switch range {
        case .week:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            return (start, now)
        case .month:
            let start = calendar.date(byAdding: .day, value: -29, to: now)!
            return (start, now)
        case .day:
            let start = calendar.startOfDay(for: now)
            return (start, now)
        }
    }

    static func fetchLeaderboard(range: LeaderboardRange, completion: @escaping ([LeaderboardEntry]) -> Void) {
        let db = Firestore.firestore()
        let (startDate, endDate) = dateRange(for: range)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startStr = dateFormatter.string(from: startDate)
        let endStr = dateFormatter.string(from: endDate)

        print("Fetching step records from \(startStr) to \(endStr)")

        db.collection("stepRecords")
            .whereField("date", isGreaterThanOrEqualTo: startStr)
            .whereField("date", isLessThanOrEqualTo: endStr)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching step records: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }

                var userStepTotals: [String: Int] = [:]

                for doc in documents {
                    let data = doc.data()
                    let uid = data["uid"] as? String ?? ""
                    let steps = data["stepCount"] as? Int ?? 0
                    userStepTotals[uid, default: 0] += steps
                }

                print("Aggregated step counts: \(userStepTotals)")

                db.collection("users").getDocuments { userSnap, error in
                    guard let users = userSnap?.documents else {
                        print("Error fetching users")
                        completion([])
                        return
                    }

                    var leaderboard: [LeaderboardEntry] = []

                    for userDoc in users {
                        let uid = userDoc.documentID
                        let name = userDoc["name"] as? String ?? "Anonymous"
                        let steps = userStepTotals[uid] ?? 0
                        leaderboard.append(LeaderboardEntry(name: name, steps: steps))
                    }

                    print("Leaderboard: \(leaderboard)")
                    completion(leaderboard.sorted(by: { $0.steps > $1.steps }))
                }
            }
        }
}

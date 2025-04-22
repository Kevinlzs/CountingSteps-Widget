//
//  HealthOverviewView.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/17/25.
//

import SwiftUI

struct HealthOverviewView: View {
    @StateObject var health = HealthKitManager()

    var body: some View {
        VStack(spacing: 16) {
            Text("🚶 Steps Today")
                .font(.headline)

            Text("\(Int(health.steps)) / \(health.stepGoal)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(health.steps >= Double(health.stepGoal) ? .green : .primary)

            Text("Distance: \(String(format: "%.2f", health.distance)) mi")
            Text("Calories: \(String(format: "%.0f", health.calories)) kcal")
        }
        .onAppear {
            health.requestAuthorization()
        }
        .padding()
    }
}

#Preview {
    HealthOverviewView()
}

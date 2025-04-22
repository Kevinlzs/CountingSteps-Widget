//
//  HealthOverviewView.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/17/25.
//

import SwiftUI

struct HealthOverviewView: View {
    @StateObject var health = HealthKitManager()
    @State private var selectedRange = "Day"
    
    private let ranges = ["Day", "Week", "Month"]

    var body: some View {
        VStack(spacing: 16) {
            Picker("Select Range", selection: $selectedRange) {
                ForEach(ranges, id: \.self) { range in
                    Text(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Text("🚶 Steps (\(selectedRange))")
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
        .onChange(of: selectedRange) { newRange in
            health.fetchAndUploadData(for: newRange)
        }
        .padding()
    }
}

#Preview {
    HealthOverviewView()
}


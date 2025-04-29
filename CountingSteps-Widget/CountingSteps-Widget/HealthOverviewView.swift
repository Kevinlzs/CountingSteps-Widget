//
//  HealthOverviewView.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/17/25.
//

import SwiftUI
import SwiftUI
import FirebaseAuth

struct HealthOverviewView: View {
    @StateObject var health = HealthKitManager()
    @State private var selectedRange = "Day"
    @State private var isLoggedOut = false
    
    private let ranges = ["Day", "Week", "Month"]
    
    private var adjustedStepGoal: Int {
        switch selectedRange {
        case "Week":
            return health.stepGoal * 7
        case "Month":
            return health.stepGoal * 30
        default:
            return health.stepGoal
        }
    }

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

            Text("\(Int(health.steps)) / \(adjustedStepGoal)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(health.steps >= Double(health.stepGoal) ? .green : .primary)

            Text("Distance: \(String(format: "%.2f", health.distance)) mi")
            Text("Calories: \(String(format: "%.0f", health.calories)) kcal")
            
            Spacer()
            
            Button(action: {
                do {
                    try Auth.auth().signOut()
                    isLoggedOut = true
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }) {
                Text("Log Out")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
        }
        .onAppear {
            health.requestAuthorization()
        }
        .onChange(of: selectedRange) { _, newRange in
            health.fetchAndUploadData(for: newRange)
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
        }
        .padding()
    }
}

#Preview {
    HealthOverviewView()
}

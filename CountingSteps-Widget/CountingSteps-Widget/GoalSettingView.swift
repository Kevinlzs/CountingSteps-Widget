//
//  GoalSettingView.swift
//  CountingSteps-Widget
//
//  Created on 4/29/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct GoalSettingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var stepGoal: Int = 10000
    @State private var originalGoal: Int = 10000
    @State private var isSaving = false
    @State private var showSuccessAlert = false
    
    private let recommendedGoals = [5000, 7500, 10000, 12500, 15000, 20000]
    private let db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.2196078449, blue: 0.2196078449, alpha: 1))]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 15) {
                        Image(systemName: "figure.run.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                            )
                        
                        Text("Set Your Step Goal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 10) {
                        Text("Your Current Goal")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(originalGoal)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("steps per day")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Select a New Goal")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                            ForEach(recommendedGoals, id: \.self) { goal in
                                Button(action: {
                                    stepGoal = goal
                                }) {
                                    Text("\(goal)")
                                        .font(.title3.bold())
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background(stepGoal == goal ? Color.green.opacity(0.8) : Color.white.opacity(0.1))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(stepGoal == goal ? Color.green : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Goal")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                TextField("", value: $stepGoal, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .font(.title3.bold())
                                
                                Stepper("", value: $stepGoal, in: 1000...50000, step: 500)
                                    .labelsHidden()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 15) {
                        Text("What This Means")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 30) {
                            goalMetricView(
                                icon: "flame.fill",
                                value: String(format: "%.0f", Double(stepGoal) * 0.05),
                                label: "calories/day",
                                color: .orange
                            )
                            
                            goalMetricView(
                                icon: "figure.walk",
                                value: String(format: "%.1f", Double(stepGoal) * 0.0008),
                                label: "miles/day",
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Button(action: {
                        saveGoal()
                    }) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Text("Save My Goal")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .disabled(isSaving || stepGoal == originalGoal)
                    .opacity(stepGoal == originalGoal ? 0.6 : 1)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            fetchCurrentGoal()
        }
        .alert("Goal Updated", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your daily step goal has been updated to \(stepGoal) steps.")
        }
    }
    
    private func fetchCurrentGoal() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let goal = document.data()?["stepGoal"] as? Int {
                    self.stepGoal = goal
                    self.originalGoal = goal
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        isSaving = true
        
        db.collection("users").document(userId).setData([
            "stepGoal": stepGoal
        ], merge: true) { error in
            isSaving = false
            
            if error == nil {
                originalGoal = stepGoal
                showSuccessAlert = true
            }
        }
    }
    
    private func goalMetricView(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(minWidth: 100)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    GoalSettingView()
}

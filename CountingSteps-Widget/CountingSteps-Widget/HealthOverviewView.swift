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
    @State private var showGoalSetting = false
    
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

    private var progressPercentage: Double {
        min(Double(health.steps) / Double(adjustedStepGoal), 1.0)
    }

    private var progressColor: Color {
        if progressPercentage >= 1.0 {
            return .green
        } else if progressPercentage >= 0.7 {
            return .yellow
        } else if progressPercentage >= 0.4 {
            return .orange
        } else {
            return .red
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)), Color(#colorLiteral(red: 0.2196078449, green: 0.2196078449, blue: 0.2196078449, alpha: 1))]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Health Overview")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                    
                    Picker("Select Range", selection: $selectedRange) {
                        ForEach(ranges, id: \.self) { range in
                            Text(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    
                    VStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.1))
                                .shadow(radius: 5)
                            
                            VStack(spacing: 15) {
                                HStack {
                                    Image(systemName: "figure.walk.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                    
                                    Text("Steps")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text(selectedRange)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                
                                Text("\(Int(health.steps))")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(health.steps >= Double(adjustedStepGoal) ? .green : .white)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 20)
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(health.steps >= Double(adjustedStepGoal) ? Color.green : Color.blue)
                                        .frame(width: max(CGFloat(progressPercentage) * (UIScreen.main.bounds.width - 80), 0), height: 20)
                                }
                                
                                Text("\(Int(health.steps)) / \(adjustedStepGoal)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(20)
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        
                        HStack(spacing: 15) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .shadow(radius: 5)
                                
                                VStack(spacing: 10) {
                                    Image(systemName: "figure.walk.motion")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                    
                                    Text("Distance")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(String(format: "%.2f", health.distance))
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("miles")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .shadow(radius: 5)
                                
                                VStack(spacing: 10) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                    
                                    Text("Calories")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(String(format: "%.0f", health.calories))
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("kcal")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                            }
                        }
                        .frame(height: 180)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    

                    ZStack{
                        Circle()
                            .stroke(lineWidth: 18)
                            .opacity(0.4)
                            .foregroundColor(.white)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(progressPercentage))
                            .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                            .foregroundColor(progressColor)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.easeInOut, value: progressPercentage)
                        
                        VStack(spacing: 5) {
                            Text("\(Int(progressPercentage * 100))%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("of goal")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 15)
                    
                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                            isLoggedOut = true
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
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
            .sheet(isPresented: $showGoalSetting) {
                GoalSettingView()
                    .onDisappear {
                        health.fetchStepGoal()
                    }
            }
            .padding()
        }
    }
}

#Preview {
    HealthOverviewView()
}



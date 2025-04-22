//
//  StepCounter.swift
//  CountingSteps-Widget
//
//  Created by Andy Hernandez on 4/17/25.
//

import SwiftUI
import HealthKit

struct StepCounterView: View {
    @ObservedObject private var stepData = StepDataManager.shared
        private let timeframes = ["Day", "Week", "Month"]
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Step Counter")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if stepData.isAuthorized {
                    Picker("Timeframe", selection: $stepData.selectedTimeframe) {
                        ForEach(0..<timeframes.count, id: \.self) { index in
                            Text(timeframes[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: stepData.selectedTimeframe) { _ in
                        stepData.fetchStepCount()
                    }
                    
                    Text("\(stepData.stepCount)")
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Steps (\(stepData.timeframeText))")
                        .font(.title2)
                    
                    Button("Refresh") {
                        stepData.fetchStepCount()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    Text("HealthKit access required")
                        .font(.title2)
                    
                    Button("Authorize HealthKit") {
                        stepData.requestAuthorization()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }


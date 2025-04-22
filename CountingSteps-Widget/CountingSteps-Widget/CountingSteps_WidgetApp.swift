//
//  CountingSteps_WidgetApp.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/15/25.
//

import SwiftUI
import FirebaseCore

@main
struct CountingSteps_WidgetApp: App {
    
    init() { // <-- Add an init
        FirebaseApp.configure() // <-- Configure Firebase app
    }

    var body: some Scene {
            WindowGroup {
                TabView {
                    StepCounterView()
                        .tabItem {
                            Image(systemName: "figure.walk")
                            Text("Steps")
                        }
                }
            }
        }
}

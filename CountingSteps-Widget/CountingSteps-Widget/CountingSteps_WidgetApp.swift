//
//  CountingSteps_WidgetApp.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/15/25.
//

import SwiftUI

@main
struct CountingSteps_WidgetApp: App {
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

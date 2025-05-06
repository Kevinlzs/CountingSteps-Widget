//
//  ContentView.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                NavigationStack {
                    LeaderboardView()
                }
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                }
                
                NavigationStack {
                    HealthOverviewView()
                }
                .tabItem {
                    Label("Health", systemImage: "heart.fill")
                }
                
                NavigationStack {
                    GoalSettingView()
                }
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                
                NavigationStack {
                    ChatView()
                }
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
            }
        }
}

#Preview {
    ContentView()
}

//
//  LeaderboardView.swift
//  CountingSteps-Widget
//
//  Created by Kevin Lopez on 4/23/25.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var entries: [LeaderboardEntry] = []
    @State private var selectedRange: LeaderboardRange = .day

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Range", selection: $selectedRange) {
                    Text("Day").tag(LeaderboardRange.day)
                    Text("Week").tag(LeaderboardRange.week)
                    Text("Month").tag(LeaderboardRange.month)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(entries.indices, id: \.self) { index in
                            let entry = entries[index]
                            let rank = index + 1
                            let (emoji, gradient) = rankStyle(for: rank)

                            HStack(spacing: 16) {
                                Text(emoji)
                                    .font(.largeTitle)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.name)
                                        .font(.title3.bold())
                                        .foregroundColor(.white)

                                    Text("\(entry.steps) steps")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }

                                Spacer()

                                Text("#\(rank)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                            .background(gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 6)
                            .padding(.horizontal)
                            .scaleEffect(rank == 1 ? 1.05 : 1.0)
                            .animation(.spring(response: 0.4), value: rank)
                        }
                    }
                    .padding(.top)
                }
            }
            .onAppear {
                LeaderboardService.fetchLeaderboard(range: selectedRange) { entries in
                    self.entries = entries
                }
            }
            .onChange(of: selectedRange) { _, _ in
                LeaderboardService.fetchLeaderboard(range: selectedRange) { entries in
                    self.entries = entries
                }
            }
            .padding(.top)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Leaderboard")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                }
            }
        }
    }

    func rankStyle(for rank: Int) -> (emoji: String, gradient: LinearGradient) {
        switch rank {
        case 1:
            return ("🥇", LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
        case 2:
            return ("🥈", LinearGradient(colors: [.gray, .black], startPoint: .top, endPoint: .bottom))
        case 3:
            return ("🥉", LinearGradient(colors: [.orange, .brown], startPoint: .top, endPoint: .bottom))
        default:
            return ("🏃‍♂️", LinearGradient(colors: [.brown, .brown], startPoint: .top, endPoint: .bottom))
        }
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}

//
//  StatsTab.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI
import Charts

struct StatsTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary cards
                    HStack {
                        StatCard(title: "Total Games", value: "\(statsVM.totalGames)")
                        StatCard(title: "Best Score", value: "\(statsVM.bestScoreOverall)")
                    }
                    .padding(.horizontal)
                    
                    // Bar chart
                    if !statsVM.sessions.isEmpty {
                        Chart {
                            ForEach(GameMode.allCases, id: \.self) { mode in
                                BarMark(
                                    x: .value("Mode", mode.rawValue),
                                    y: .value("Best Score", statsVM.bestScore(for: mode))
                                )
                                .foregroundStyle(by: .value("Mode", mode.rawValue))
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        Text("No games played yet")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                    // Recent games list
                    if !statsVM.sessions.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Games")
                                .font(.headline)
                                .padding(.horizontal)
                            ForEach(statsVM.sessions.suffix(10).reversed()) { session in
                                HStack {
                                    Text(session.mode.rawValue)
                                    Spacer()
                                    Text("\(session.score)")
                                        .fontWeight(.bold)
                                    Text(session.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Stats")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

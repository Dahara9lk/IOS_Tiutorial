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
            ZStack {
                // ✅ Theme Background
                LinearGradient.mainGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Summary cards
                        HStack {
                            StatCard(title: "Total Games", value: "\(statsVM.totalGames)", color: .cyan)
                            StatCard(title: "Best Score", value: "\(statsVM.bestScoreOverall)", color: .yellow)
                        }
                        .padding(.horizontal)
                        
                        // Bar chart
                        if !statsVM.sessions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📊 SCORE BY MODE")
                                    .font(.system(.caption, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal)
                                
                                Chart {
                                    ForEach(GameMode.allCases, id: \.self) { mode in
                                        BarMark(
                                            x: .value("Mode", mode.rawValue),
                                            y: .value("Best Score", statsVM.bestScore(for: mode))
                                        )
                                        .foregroundStyle(by: .value("Mode", mode.rawValue))
                                        .cornerRadius(8)
                                    }
                                }
                                .frame(height: 200)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal)
                            }
                        } else {
                            Text("No games played yet")
                                .font(.system(.headline, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                                .padding()
                        }
                        
                        // Recent games list
                        if !statsVM.sessions.isEmpty {
                            VStack(alignment: .leading) {
                                Text("🕐 RECENT GAMES")
                                    .font(.system(.caption, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal)
                                
                                ForEach(statsVM.recentSessions) { session in
                                    HStack {
                                        Image(systemName: session.mode.iconName)
                                            .foregroundColor(session.mode == .tapFrenzy ? .tapFrenzyColor : session.mode == .lightItUp ? .lightItUpColor : .quizRushColor)
                                            .font(.caption)
                                        
                                        Text(session.mode.rawValue)
                                            .font(.system(.body, design: .monospaced))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text("\(session.score)")
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow)
                                        
                                        Text(session.timestamp, style: .date)
                                            .font(.system(.caption2, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.03))
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("📊 STATS")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 5)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.largeTitle, design: .monospaced))
                .fontWeight(.black)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 5)
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

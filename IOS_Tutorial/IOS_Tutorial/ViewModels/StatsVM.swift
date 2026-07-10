//
//  StatsVM.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI
import Combine

class StatsViewModel: ObservableObject {
    @Published var sessions: [GameSession] = []
    
    init() {
        loadSessions()
    }
    
    // MARK: - Persistence
    func addSession(_ session: GameSession) {
        sessions.append(session)
        saveSessions()
    }
    
    func loadSessions() {
        sessions = UserDefaults.standard.loadSessions()
    }
    
    func saveSessions() {
        UserDefaults.standard.saveSessions(sessions)
    }
    
    func resetStats() {
        sessions.removeAll()
        saveSessions()
    }
    
    // MARK: - Computed Properties
    
    var totalGames: Int {
        sessions.count
    }
    
    var bestScoreOverall: Int {
        sessions.map(\.score).max() ?? 0
    }
    
    var averageScoreOverall: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(sessions.map(\.score).reduce(0, +)) / Double(sessions.count)
    }
    
    // MARK: - Per Mode Stats
    
    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }
    
    func averageScore(for mode: GameMode) -> Double {
        let filtered = sessions.filter { $0.mode == mode }
        guard !filtered.isEmpty else { return 0 }
        return Double(filtered.map(\.score).reduce(0, +)) / Double(filtered.count)
    }
    
    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }
    
    func totalGames(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }
    
    // MARK: - Recent Games
    
    var recentSessions: [GameSession] {
        Array(sessions.suffix(10).reversed())
    }
}

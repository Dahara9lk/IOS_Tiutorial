//
//  GameSession.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import Foundation
import CoreLocation
import MapKit

// MARK: - Game Session Model
struct GameSession: Identifiable, Codable {
    let id: UUID
    let mode: GameMode      // ✅ Uses GameMode from GameMode.swift
    let score: Int
    let timestamp: Date
    let latitude: Double?
    let longitude: Double?
    
    init(mode: GameMode, score: Int, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID()
        self.mode = mode
        self.score = score
        self.timestamp = Date()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Computed property to get coordinates
    var locationCoordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    private static let sessionsKey = "gameSessions"
    
    func saveSessions(_ sessions: [GameSession]) {
        if let data = try? JSONEncoder().encode(sessions) {
            set(data, forKey: Self.sessionsKey)
        }
    }
    
    func loadSessions() -> [GameSession] {
        guard let data = data(forKey: Self.sessionsKey),
              let sessions = try? JSONDecoder().decode([GameSession].self, from: data) else {
            return []
        }
        return sessions
    }
}

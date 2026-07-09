//
//  GameMode.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import Foundation

enum GameMode: String, Codable, CaseIterable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    // Helper for SF Symbol icons
    var iconName: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }
    
    // Helper for colors
    var color: String {
        switch self {
        case .tapFrenzy: return "blue"
        case .lightItUp: return "orange"
        case .quizRush: return "purple"
        }
    }
}

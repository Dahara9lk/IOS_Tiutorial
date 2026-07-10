//
//  Color+Theme.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-07-10.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let primaryGradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [.orange, .red],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [.green, .mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Game Specific Colors
    static let tapFrenzyColor = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let lightItUpColor = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let quizRushColor = Color(red: 0.6, green: 0.2, blue: 0.8)
    
    // MARK: - Dark/Light Mode Adaptive Colors
    static let cardBackground = Color("CardBackground")
    static let cardForeground = Color("CardForeground")
    static let gameBackground = Color("GameBackground")
    static let secondaryText = Color("SecondaryText")
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.1, green: 0.05, blue: 0.2),
            Color(red: 0.2, green: 0.1, blue: 0.4)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let neonGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.0, green: 0.8, blue: 1.0),
            Color(red: 0.5, green: 0.0, blue: 1.0)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

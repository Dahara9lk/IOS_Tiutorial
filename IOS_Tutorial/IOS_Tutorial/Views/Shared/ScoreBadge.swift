//
//  ScoreBadge.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI

/// A reusable badge component for displaying scores with a consistent style
struct ScoreBadge: View {
    let score: Int
    let label: String?
    let mode: GameMode?
    let size: BadgeSize
    
    // MARK: - Initializers
    init(score: Int, label: String? = nil, mode: GameMode? = nil, size: BadgeSize = .medium) {
        self.score = score
        self.label = label
        self.mode = mode
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon based on mode
            if let mode = mode {
                Image(systemName: iconName(for: mode))
                    .font(size == .small ? .caption : .body)
                    .foregroundColor(color(for: mode))
            }
            
            // Label text
            if let label = label {
                Text(label)
                    .font(size == .small ? .caption : .subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Score value
            Text("\(score)")
                .font(size == .small ? .headline : .title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, size == .small ? 10 : 16)
        .padding(.vertical, size == .small ? 6 : 10)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            Capsule()
                .stroke(mode != nil ? color(for: mode!).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    // MARK: - Helper Functions
    private func iconName(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy:
            return "hand.tap.fill"
        case .lightItUp:
            return "lightbulb.fill"
        case .quizRush:
            return "questionmark.circle.fill"
        }
    }
    
    private func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy:
            return .blue
        case .lightItUp:
            return .orange
        case .quizRush:
            return .purple
        }
    }
}

// MARK: - Badge Size
enum BadgeSize {
    case small
    case medium
    case large
    
    var scale: CGFloat {
        switch self {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.2
        }
    }
}

// MARK: - Convenience Extensions
extension ScoreBadge {
    /// Creates a score badge without mode icon
    static func plain(score: Int, label: String? = nil, size: BadgeSize = .medium) -> some View {
        ScoreBadge(score: score, label: label, mode: nil, size: size)
    }
    
    /// Creates a score badge for a specific game mode
    static func forMode(_ mode: GameMode, score: Int, size: BadgeSize = .medium) -> some View {
        ScoreBadge(score: score, label: mode.rawValue, mode: mode, size: size)
    }
}

// MARK: - Preview
#Preview("Score Badge - Different Modes") {
    VStack(spacing: 20) {
        ScoreBadge(score: 42, label: "Total", mode: .tapFrenzy)
        ScoreBadge(score: 100, label: "Best", mode: .lightItUp, size: .large)
        ScoreBadge(score: 7, label: "Streak", mode: .quizRush, size: .small)
        ScoreBadge.plain(score: 999, label: "Overall")
    }
    .padding()
}

#Preview("Score Badge - Game Over") {
    VStack(spacing: 20) {
        // For use in result screens
        HStack {
            ScoreBadge(score: 47, label: "Score", mode: .quizRush)
            ScoreBadge(score: 3, label: "Streak", mode: .quizRush, size: .small)
        }
    }
    .padding()
}

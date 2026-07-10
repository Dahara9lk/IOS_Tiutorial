//
//  ResultView.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let mode: GameMode
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    
    var shareText: String {
        "I just scored \(score) on \(mode.rawValue) — beat that! 🎮"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            Text("Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Score: \(score)")
                .font(.title)
            
            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button("Play Again", action: onPlayAgain)
                    .buttonStyle(.borderedProminent)
                Button("Home", action: onHome)
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }
}

#Preview {
    ResultView(
        score: 42,
        mode: .quizRush,
        onPlayAgain: {},
        onHome: {}
    )
}

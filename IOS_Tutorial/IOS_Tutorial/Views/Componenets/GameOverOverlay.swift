//
//  GameOverOverlay.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

struct GameOverOverlay: View {
    let score: Int
    let highScore: Int
    let isNewHighScore: Bool
    let onRestart: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("GAME OVER")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("Score: \(score)")
                .font(.title)
            
            if isNewHighScore {
                Text("🏆 NEW HIGH SCORE! 🏆")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
            }
            
            Text("High Score: \(highScore)")
                .font(.headline)
            
            HStack(spacing: 20) {
                Button(action: onRestart) {
                    Text("Play Again")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: onHome) {
                    Text("Home")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }
}

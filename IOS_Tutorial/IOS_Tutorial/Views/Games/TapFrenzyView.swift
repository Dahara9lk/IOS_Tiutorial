//
//  TapFrenzyView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

struct TapFrenzyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var score = 0
    @State private var timeRemaining = 12
    @State private var isGameActive = false
    @State private var timer: Timer?
    @State private var showGameOver = false
    
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Tap Frenzy")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            // Score and Time
            VStack(spacing: 20) {
                Text("\(score)")
                    .font(.system(size: 60, weight: .bold))
                
                Text("Time: \(timeRemaining)s")
                    .font(.title2)
                    .foregroundColor(timeRemaining <= 5 ? .red : .primary)
                
                if !isGameActive {
                    Button(action: startGame) {
                        Text("Start Game")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            // Tap Button
            Button(action: handleTap) {
                Circle()
                    .fill(isGameActive ? Color.blue : Color.gray)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("TAP")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .scaleEffect(isGameActive ? 1.0 : 0.9)
                    .animation(.easeInOut(duration: 0.2), value: isGameActive)
            }
            .disabled(!isGameActive)
            
            Spacer()
        }
        .overlay(
            Group {
                if showGameOver {
                    GameOverOverlay(
                        score: score,
                        highScore: highScore,
                        isNewHighScore: score > highScore,
                        onRestart: startGame,
                        onHome: { dismiss() }
                    )
                }
            }
        )
        .onDisappear {
            stopGame()
        }
    }
    
    private func startGame() {
        score = 0
        timeRemaining = 30
        isGameActive = true
        showGameOver = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            
            if timeRemaining <= 0 {
                endGame()
            }
        }
    }
    
    private func stopGame() {
        timer?.invalidate()
        timer = nil
        isGameActive = false
    }
    
    private func handleTap() {
        guard isGameActive else { return }
        score += 1
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func endGame() {
        stopGame()
        if score > highScore {
            highScore = score
        }
        showGameOver = true
    }
}

//
//  TapFrenzyView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI
import CoreLocation

struct TapFrenzyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    
    //Storage of app
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    //State
    @State private var score = 0
    @State private var timeRemaining = 12
    @State private var isGameActive = false
    @State private var timer: Timer?
    @State private var showGameOver = false
    
    //@AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    //Body
    var body: some View {
            VStack {
                // Header
                HStack {
                    Spacer()
                    
                    Text("Tap Frenzy")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Score display
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(score)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.blue.opacity(0.1)))
                }
                .padding()
                
                // Game Area
                VStack(spacing: 20) {
                    // Score Display
                    Text("\(score)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.blue)
                    
                    // Time Display
                    Text("Time: \(timeRemaining)s")
                        .font(.title2)
                        .foregroundColor(timeRemaining <= 5 ? .red : .primary)
                    
                    // High Score
                    Text("High Score: \(highScore)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Tap Button
                    Button(action: {
                        if isGameActive {
                            handleTap()
                        } else {
                            startGame()
                        }
                    }) {
                        Circle()
                            .fill(isGameActive ? Color.blue : Color.green)
                            .frame(width: 200, height: 200)
                            .overlay(
                                Text(isGameActive ? "TAP" : "START")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .scaleEffect(isGameActive ? 1.0 : 0.9)
                            .animation(.easeInOut(duration: 0.2), value: isGameActive)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .overlay(
                Group {
                    if showGameOver {
                        ResultView(
                            score: score,
                            mode: .tapFrenzy,
                            onPlayAgain: startGame,
                            onHome: { dismiss() }
                        )
                    }
                }
            )
            .onDisappear {
                stopGame()
            }
        }
        
        // Logic of the Game
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
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        private func stopGame() {
            timer?.invalidate()
            timer = nil
            isGameActive = false
        }
        
        private func handleTap() {
            guard isGameActive else { return }
            score += 1
            
            // Light haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        private func endGame() {
            stopGame()
            
            // Update high score
            if score > highScore {
                highScore = score
            }
            
            // Record session
            let session = GameSession(
                mode: .tapFrenzy,
                score: score,
                latitude: locationService.currentLocation?.coordinate.latitude,
                longitude: locationService.currentLocation?.coordinate.longitude
            )
            statsVM.addSession(session)
            
            showGameOver = true
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    #Preview {
        TapFrenzyView()
            .environmentObject(StatsViewModel())
            .environmentObject(LocationService())
    }

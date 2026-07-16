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
    
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isGameActive = false
    @State private var timer: Timer?
    @State private var showGameOver = false
    @State private var taps: [CGPoint] = []
    @State private var tapCount = 0
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // ✅ Theme Background
            LinearGradient.mainGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Spacer()
                    
                    Text("⚡ TAP FRENZY")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.cyan)
                        .shadow(color: .cyan.opacity(0.5), radius: 5)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Score Display
                VStack(spacing: 8) {
                    Text("\(score)")
                        .font(.system(size: 72, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.3), radius: 10)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("TIME")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                            Text("\(timeRemaining)s")
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(timeRemaining <= 5 ? .red : .white)
                        }
                        
                        VStack {
                            Text("BEST")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                            Text("\(highScore)")
                                .font(.system(.title2, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // ✅ Tap Button with Theme
                Button(action: handleTap) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                            )
                            .shadow(
                                color: Color.cyan.opacity(0.3),
                                radius: 15
                            )
                            .scaleEffect(isGameActive ? 0.95 : 1.0)
                            .animation(.spring(), value: isGameActive)
                        
                        Text("TAP")
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                    }
                }
                .offset(x: xOffset, y: yOffset)
                .animation(.easeInOut(duration: 0.2), value: xOffset)
                
                Spacer()
                
                if !isGameActive && !showGameOver {
                    Text("TAP TO START")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 30)
                }
            }
            .padding()
        }
        .overlay {
            if showGameOver {
                // ✅ Game Over with Theme
                VStack(spacing: 25) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 20)
                    
                    Text("GAME OVER!")
                        .font(.system(.largeTitle, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("SCORE: \(score)")
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.3), radius: 5)
                    
                    if score > highScore {
                        Text("🏆 NEW HIGH SCORE!")
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .shadow(color: .green.opacity(0.3), radius: 5)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: startGame) {
                            Text("🔄 REPLAY")
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.purple)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .shadow(color: .purple.opacity(0.3), radius: 10)
                        }
                        
                        Button(action: {
                            dismiss()
                            statsVM.addSession(GameSession(
                                mode: .tapFrenzy,
                                score: score,
                                latitude: locationService.currentLocation?.coordinate.latitude,
                                longitude: locationService.currentLocation?.coordinate.longitude
                            ))
                        }) {
                            Text("🏠 HOME")
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(30)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onDisappear {
            stopGame()
        }
    }
    
    private func startGame() {
        score = 0
        timeRemaining = 30
        isGameActive = true
        showGameOver = false
        tapCount = 0
        taps.removeAll()
        
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
        if !isGameActive && !showGameOver {
            startGame()
        }
        guard isGameActive else { return }
        score += 1
        tapCount += 1
        
        xOffset = CGFloat.random(in: -120...120)
        yOffset = CGFloat.random(in: -200...200)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func endGame() {
        stopGame()
        if score > highScore {
            highScore = score
        }
        
        let session = GameSession(
            mode: .tapFrenzy,
            score: score,
            latitude: locationService.currentLocation?.coordinate.latitude,
            longitude: locationService.currentLocation?.coordinate.longitude
        )
        statsVM.addSession(session)
        
        showGameOver = true
    }
}

#Preview {
    TapFrenzyView()
        .environmentObject(StatsViewModel())
        .environmentObject(LocationService())
}

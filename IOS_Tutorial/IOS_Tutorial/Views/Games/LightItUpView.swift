//
//  LightItUpView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI
import CoreLocation

struct LightItUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    
    @AppStorage("lightItUpHighScore") private var highScore = 0
    
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeRemaining = 60
    @State private var currentLevel: Level = .l1
    @State private var timer: Timer?
    @State private var litTimer: Timer?
    @State private var isGameActive = false
    @State private var showLevelUp = false
    @State private var showGameOver = false
    @State private var selectedDuration = 60
    @State private var showSettings = false
    
    let durationOptions = [30, 60, 90]
    
    var body: some View {
        ZStack {
            // ✅ Theme Background
            LinearGradient.mainGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Text("💡 LIGHT IT UP")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.5), radius: 5)
                    
                    Spacer()
                    
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                
                // Stats
                HStack {
                    VStack {
                        Text("SCORE")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                        Text("\(score)")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.3), radius: 5)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("LIVES")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                        HStack {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .foregroundColor(index < lives ? .red : .gray)
                                    .font(.title2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("TIME")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                        Text("\(timeRemaining)s")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(timeRemaining <= 10 ? .red : .white)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // Level Indicator
                Text("LEVEL \(currentLevel.rawValue)")
                    .font(.system(.headline, design: .monospaced))
                    .fontWeight(.black)
                    .foregroundColor(currentLevel.glowColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(currentLevel.glowColor.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(currentLevel.glowColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: currentLevel.glowColor.opacity(0.3), radius: 10)
                    .padding(.vertical, 8)
                
                // Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: currentLevel.columns), spacing: 8) {
                    ForEach(cards) { card in
                        LightItUpGameCard(card: card, level: currentLevel)
                            .onTapGesture {
                                handleTap(card: card)
                            }
                    }
                }
                .padding()
                .frame(maxHeight: .infinity)
                
                // Start Button
                if !isGameActive && !showGameOver {
                    Button(action: startGame) {
                        Text("🚀 START")
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.orange)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .orange.opacity(0.3), radius: 10)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(selectedDuration: $selectedDuration)
        }
        .overlay(
            Group {
                if showLevelUp {
                    LevelUpOverlay(level: currentLevel)
                }
                if showGameOver {
                    // ✅ Game Over with Theme
                    VStack(spacing: 25) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.5), radius: 20)
                        
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
                                            .fill(Color.orange)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .orange.opacity(0.3), radius: 10)
                            }
                            
                            Button(action: { dismiss() }) {
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
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(30)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .onDisappear {
            stopGame()
        }
    }
    
    // MARK: - Game Logic
    private func initializeCards() {
        cards = (0..<currentLevel.totalCards).map { Card(position: $0) }
    }
    
    private func startGame() {
        score = 0
        lives = 3
        timeRemaining = selectedDuration
        currentLevel = .l1
        initializeCards()
        isGameActive = true
        showGameOver = false
        showLevelUp = false
        
        startMainTimer()
        startLitTimer()
    }
    
    private func stopGame() {
        timer?.invalidate()
        litTimer?.invalidate()
        timer = nil
        litTimer = nil
        isGameActive = false
        
        for i in cards.indices {
            cards[i].isLit = false
        }
    }
    
    private func startMainTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            
            let newLevel = Level.from(time: selectedDuration - timeRemaining)
            if newLevel != currentLevel {
                withAnimation(.spring()) {
                    currentLevel = newLevel
                    showLevelUp = true
                    initializeCards()
                    startLitTimer()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showLevelUp = false
                }
            }
            
            if timeRemaining <= 0 {
                endGame()
            }
        }
    }
    
    private func startLitTimer() {
        litTimer?.invalidate()
        litTimer = Timer.scheduledTimer(withTimeInterval: currentLevel.litDuration, repeats: true) { _ in
            if isGameActive {
                lightUpCards()
            }
        }
    }
    
    private func lightUpCards() {
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        let availableIndices = cards.indices.filter { !cards[$0].isLit }
        let countToLight = min(currentLevel.litCount, availableIndices.count)
        
        if countToLight > 0 {
            let shuffledIndices = availableIndices.shuffled()
            for i in 0..<countToLight {
                withAnimation(.easeInOut(duration: 0.3)) {
                    cards[shuffledIndices[i]].isLit = true
                }
            }
        }
    }
    
    private func handleTap(card: Card) {
        guard isGameActive else { return }
        
        if card.isLit {
            score += 1
            withAnimation(.easeOut(duration: 0.2)) {
                if let index = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[index].isLit = false
                }
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else {
            lives -= 1
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            if lives <= 0 {
                endGame()
            }
        }
    }
    
    private func endGame() {
        stopGame()
        
        if score > highScore {
            highScore = score
        }
        
        let session = GameSession(
            mode: .lightItUp,
            score: score,
            latitude: locationService.currentLocation?.coordinate.latitude,
            longitude: locationService.currentLocation?.coordinate.longitude
        )
        statsVM.addSession(session)
        
        showGameOver = true
    }
}

// MARK: - Light It Up Card
struct LightItUpGameCard: View {
    let card: Card
    let level: Level
    
    var body: some View {
        Rectangle()
            .fill(card.isLit ? level.glowColor : Color.white.opacity(0.05))
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(12)
            .scaleEffect(card.isLit ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: card.isLit)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(card.isLit ? level.glowColor : Color.white.opacity(0.1), lineWidth: card.isLit ? 3 : 1)
                    .shadow(color: card.isLit ? level.glowColor.opacity(0.5) : .clear, radius: card.isLit ? 10 : 0)
            )
    }
}


#Preview {
    LightItUpView()
        .environmentObject(StatsViewModel())
        .environmentObject(LocationService())
}

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
    
    // Storage of the App
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
    
    //Body
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Light It Up")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            }
            .padding()
            
            // Stats
            HStack {
                VStack {
                    Text("Score")
                        .font(.caption)
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack {
                    Text("Lives")
                        .font(.caption)
                    HStack {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < lives ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("Time")
                        .font(.caption)
                    Text("\(timeRemaining)s")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(timeRemaining <= 10 ? .red : .primary)
                }
            }
            .padding(.horizontal)
            
            // Level Indicator
            Text("Level \(currentLevel.rawValue)")
                .font(.headline)
                .foregroundColor(currentLevel.glowColor)
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(currentLevel.glowColor.opacity(0.2))
                .cornerRadius(10)
            
            // Grid - ✅ Using LightItUpCardView from CardView.swift
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: currentLevel.columns), spacing: 8) {
                ForEach(cards) { card in
                    GameCardView(card: card, level: currentLevel)  // ✅ Updated name
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
                    Text("Start Game")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                }
                .padding()
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
                    ResultView(
                        score: score,
                        mode: .lightItUp,
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
        
        // Turn off all lights
        for i in cards.indices {
            cards[i].isLit = false
        }
    }
    
    private func startMainTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            
            // Check level progression
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
        // Turn off all cards
        for i in cards.indices {
            cards[i].isLit = false
        }
        
        // Pick cards to light up
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
            // Correct tap
            score += 1
            withAnimation(.easeOut(duration: 0.2)) {
                if let index = cards.firstIndex(where: { $0.id == card.id }) {
                    cards[index].isLit = false
                }
            }
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else {
            // Wrong tap - lose a life
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
        
        // Update high score
        if score > highScore {
            highScore = score
        }
        
        // Record session
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


#Preview {
    LightItUpView()
        .environmentObject(StatsViewModel())
        .environmentObject(LocationService())
}

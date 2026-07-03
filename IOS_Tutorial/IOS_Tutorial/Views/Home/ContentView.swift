//
//  ContentView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-13.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMode: GameMode?
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore = 0
    
    enum GameMode {
        case tapFrenzy, lightItUp, quizRush
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                Text("BSCCOMP25.1P")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("GAME MODES")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                // Game Mode Buttons
                Button(action: { selectedMode = .tapFrenzy }) {
                    GameModeCard(
                        title: "Tap Frenzy",
                        subtitle: "Classic tap challenge",
                        highScore: tapFrenzyHighScore,
                        color: .blue,
                        iconName: "hand.tap.fill"
                    )
                }
                
                Button(action: { selectedMode = .lightItUp }) {
                    GameModeCard(
                        title: "Light It Up",
                        subtitle: "Whack-a-mole style",
                        highScore: lightItUpHighScore,
                        color: .orange,
                        iconName: "lightbulb.fill"
                    )
                }
                
                Button(action: { selectedMode = .quizRush }) {
                    GameModeCard(
                        title: "Quiz Rush",
                        subtitle: "Live trivia challenge",
                        highScore: quizRushHighScore,
                        color: .purple,
                        iconName: "questionmark.circle.fill"
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationDestination(item: $selectedMode) { mode in
                switch mode {
                case .tapFrenzy:
                    TapFrenzyView()
                case .lightItUp:
                    LightItUpView()
                case .quizRush:
                    QuizRushView()
                }
            }
        }
    }
}

// MARK: - Updated Game Mode Card
struct GameModeCard: View {
    let title: String
    let subtitle: String
    let highScore: Int
    let color: Color
    let iconName: String
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("High Score: \(highScore)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.leading, 4)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(color.gradient)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}

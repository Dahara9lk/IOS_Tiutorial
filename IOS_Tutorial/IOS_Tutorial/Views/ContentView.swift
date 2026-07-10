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
                Text("GAME TIME")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("GAME MODES")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
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

#Preview {
    ContentView()
}

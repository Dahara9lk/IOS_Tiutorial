//
//  ContentView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMode: GameMode?
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    
    enum GameMode {
        case tapFrenzy, lightItUp
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Explore the Game World!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                Text("GAME MODES")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Button(action: { selectedMode = .tapFrenzy }) {
                    GameModeCard(
                        title: "Tap Frenzy",
                        subtitle: "Classic mode",
                        highScore: tapFrenzyHighScore,
                        color: .blue
                    )
                }
                
                Button(action: { selectedMode = .lightItUp }) {
                    GameModeCard(
                        title: "Light It Up",
                        subtitle: "Whack-a-mole style",
                        highScore: lightItUpHighScore,
                        color: .orange
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
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

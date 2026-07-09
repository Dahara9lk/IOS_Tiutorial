//
//  HomeTab.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI

struct HomeTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
    @State private var selectedMode: GameMode?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                Text("PlayHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("Choose your game")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                ForEach(GameMode.allCases, id: \.self) { mode in
                    Button(action: { selectedMode = mode }) {
                        GameModeCard(
                            title: mode.rawValue,
                            subtitle: mode == .tapFrenzy ? "Tap as fast as you can" :
                                      mode == .lightItUp ? "Whack-a-mole style" : "Live trivia",
                            highScore: statsVM.bestScore(for: mode),
                            color: mode == .tapFrenzy ? .blue : mode == .lightItUp ? .orange : .purple,
                            iconName: mode == .tapFrenzy ? "hand.tap.fill" :
                                      mode == .lightItUp ? "lightbulb.fill" : "questionmark.circle.fill"
                        )
                    }
                }
                Spacer()
            }
            .padding()
            .navigationDestination(item: $selectedMode) { mode in
                switch mode {
                case .tapFrenzy: TapFrenzyView()
                case .lightItUp: LightItUpView()
                case .quizRush: QuizRushView()
                }
            }
        }
    }
}

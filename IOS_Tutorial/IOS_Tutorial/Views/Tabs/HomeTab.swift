//
//  HomeTab.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import SwiftUI

struct HomeTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    @State private var selectedMode: GameMode?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // ✅ Theme Background
                LinearGradient.mainGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("🎮 PLAYHUB")
                        .font(.system(.largeTitle, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                        .padding(.top, 40)
                    
                    Text("Choose your game")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Button(action: { selectedMode = mode }) {
                            GameModeCard(
                                title: mode.rawValue,
                                subtitle: mode == .tapFrenzy ? "Tap as fast as you can" :
                                          mode == .lightItUp ? "Whack-a-mole style" : "Live trivia",
                                highScore: statsVM.bestScore(for: mode),
                                color: mode == .tapFrenzy ? .tapFrenzyColor :
                                       mode == .lightItUp ? .lightItUpColor : .quizRushColor,
                                iconName: mode.iconName
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .padding()
            }
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


//
//  LevelUpOverlay.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

struct LevelUpOverlay: View {
    let level: Level
    
    var body: some View {
        VStack {
            Spacer()
            Text("LEVEL UP!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(level.glowColor)
                .shadow(color: level.glowColor.opacity(0.5), radius: 20)
            Text("Level \(level.rawValue)")
                .font(.title)
                .foregroundColor(.white)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        .transition(.opacity)
    }
}

//
//  GameModeCard.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

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
            
            VStack(alignment: .leading, spacing: 8) {
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

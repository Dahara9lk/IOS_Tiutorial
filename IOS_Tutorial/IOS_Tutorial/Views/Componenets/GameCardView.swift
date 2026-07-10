//
//  CardView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

// ✅ Renamed from CardView to GameCardView to avoid conflict
struct GameCardView: View {
    let card: Card
    let level: Level
    
    var body: some View {
        Rectangle()
            .fill(card.isLit ? level.glowColor : Color.gray.opacity(0.3))
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(12)
            .scaleEffect(card.isLit ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: card.isLit)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(card.isLit ? level.glowColor : Color.clear, lineWidth: 3)
                    .shadow(color: card.isLit ? level.glowColor.opacity(0.5) : .clear, radius: 8)
            )
    }
}

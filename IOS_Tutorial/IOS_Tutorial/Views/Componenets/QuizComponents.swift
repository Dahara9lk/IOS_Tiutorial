//
//  QuizComponents.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//

import SwiftUI

// MARK: - Answer Button with Hover Effect
struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let state: AnswerState
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(isHovered && !isDisabled && state == .none ? 1.03 : 1.0)
            .shadow(
                color: isHovered && !isDisabled && state == .none ? Color.purple.opacity(0.3) : .clear,
                radius: isHovered && !isDisabled && state == .none ? 10 : 0
            )
        }
        .disabled(isDisabled || state != .none)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: state)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
    
    private var backgroundColor: Color {
        switch state {
        case .correct:
            return Color.green.opacity(0.2)
        case .wrong:
            return Color.red.opacity(0.2)
        default:
            if isSelected {
                return Color.purple.opacity(0.2)
            }
            return isHovered ? Color.purple.opacity(0.1) : Color.gray.opacity(0.08)
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .correct:
            return .green
        case .wrong:
            return .red
        default:
            return isSelected ? .purple : .primary
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .correct:
            return .green
        case .wrong:
            return .red
        default:
            if isSelected {
                return .purple
            }
            return isHovered ? Color.purple.opacity(0.4) : Color.clear
        }
    }
}

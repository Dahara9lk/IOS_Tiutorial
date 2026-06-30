//
//  QuizComponents.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//

import SwiftUI

// MARK: - Question Progress View
struct QuestionProgressView: View {
    let current: Int
    let total: Int
    let streak: Int
    
    var body: some View {
        HStack {
            Text("Question \(current + 1) of \(total)")
                .font(.headline)
            
            Spacer()
            
            if streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(streak)")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - Quiz Score View
struct QuizScoreView: View {
    let score: Int
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.blue.opacity(0.1)))
    }
}

// MARK: - Answer Button
struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let state: AnswerState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
                .scaleEffect(isSelected ? 0.98 : 1.0)
        }
        .disabled(state != .none)
        .animation(.easeInOut(duration: 0.2), value: state)
    }
    
    private var backgroundColor: Color {
        switch state {
        case .correct:
            return Color.green.opacity(0.2)
        case .wrong:
            return Color.red.opacity(0.2)
        default:
            return isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .correct:
            return .green
        case .wrong:
            return .red
        default:
            return .primary
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .correct:
            return .green
        case .wrong:
            return .red
        default:
            return isSelected ? .blue : Color.clear
        }
    }
}

// MARK: - Loading State View
struct QuizLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Questions...")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Fetching from Open Trivia DB")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State View
struct QuizErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Quiz Finished View
struct QuizFinishedView: View {
    let score: Int
    let maxStreak: Int
    let totalQuestions: Int
    let onPlayAgain: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Quiz Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Score:")
                        .font(.headline)
                    Text("\(score)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Best Streak:")
                        .font(.headline)
                    Text("\(maxStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Text("\(score)/\(totalQuestions)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: onHome) {
                    Text("Home")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

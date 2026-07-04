//
//  QuizRushView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.


//
//  QuizRushView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//

import SwiftUI

struct QuizRushView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = QuizViewModel()
    @AppStorage("quizRushHighScore") private var highScore = 0
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                }
                Spacer()
                Text("Quiz Rush")
                    .font(.headline)
                Spacer()
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.blue.opacity(0.1)))
            }
            .padding()
            
            // Content
            if viewModel.state == .loading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading Questions...")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.state == .loaded, let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress
                        HStack {
                            Text("Question \(viewModel.currentIndex + 1) of 10")
                            Spacer()
                            if viewModel.streak > 0 {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                    Text("\(viewModel.streak)")
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Question
                        VStack(spacing: 12) {
                            Text(question.category)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            Text(question.question)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                        
                        // Answers
                        ForEach(question.allAnswers, id: \.self) { answer in
                            Button(action: {
                                viewModel.selectAnswer(answer)
                            }) {
                                Text(answer)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(buttonColor(answer))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(buttonBorder(answer), lineWidth: 2)
                                    )
                            }
                            .disabled(viewModel.isAnswering)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            } else if viewModel.state == .finished {
                // Finished
                VStack(spacing: 25) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    Text("Quiz Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Score: \(viewModel.score)")
                        .font(.title)
                    Text("Best Streak: \(viewModel.streak)")
                        .font(.headline)
                    
                    Button(action: {
                        viewModel.reset()
                        Task {
                            await viewModel.loadQuestions()
                        }
                    }) {
                        Text("Play Again")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button(action: { dismiss() }) {
                        Text("Home")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .onAppear {
                    if viewModel.score > highScore {
                        highScore = viewModel.score
                    }
                }
            } else {
                // Idle or error - show start button
                VStack {
                    Text("Ready to play?")
                        .font(.title2)
                    Button(action: {
                        Task {
                            await viewModel.loadQuestions()
                        }
                    }) {
                        Text("Start Quiz")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 50)
                }
            }
        }
        .task {
            await viewModel.loadQuestions()
        }
    }
    
    func buttonColor(_ answer: String) -> Color {
        if viewModel.selectedAnswer == answer {
            if viewModel.answerState == .correct {
                return Color.green.opacity(0.3)
            } else if viewModel.answerState == .wrong {
                return Color.red.opacity(0.3)
            }
            return Color.blue.opacity(0.2)
        }
        return Color.gray.opacity(0.1)
    }
    
    func buttonBorder(_ answer: String) -> Color {
        if viewModel.selectedAnswer == answer {
            if viewModel.answerState == .correct {
                return .green
            } else if viewModel.answerState == .wrong {
                return .red
            }
            return .blue
        }
        return Color.clear
    }
}

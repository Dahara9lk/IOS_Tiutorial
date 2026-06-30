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
    @State private var showErrorAlert = false
    @AppStorage("quizRushHighScore") private var highScore = 0
    var body: some View {
        VStack {
            // Header
            QuizHeaderView(
                onBack: { dismiss() },
                score: viewModel.score
            )
            
            // Content
            contentView
        }
        .task {
            await viewModel.loadQuestions()
        }
        .onChange(of: viewModel.viewState) { newState in
            if case .failed(let error) = newState {
                showErrorAlert = true
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Retry") {
                Task {
                    await viewModel.loadQuestions()
                }
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        } message: {
            if case .failed(let error) = viewModel.viewState {
                Text(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewState {
        case .idle:
            Color.clear
            
        case .loading:
            QuizLoadingView()
            
        case .loaded:
            if let question = viewModel.currentQuestion {
                QuizQuestionView(
                    question: question,
                    currentIndex: viewModel.currentIndex,
                    totalQuestions: viewModel.questions.count,
                    streak: viewModel.streak,
                    selectedAnswer: viewModel.selectedAnswer,
                    answerState: viewModel.answerState,
                    isAnswering: viewModel.isAnswering,
                    onAnswerSelected: { answer in
                        viewModel.selectAnswer(answer)
                    }
                )
            }
            
        case .failed:
            QuizErrorView(
                error: QuizServiceError.noData,
                onRetry: {
                    Task {
                        await viewModel.loadQuestions()
                    }
                }
            )
            
        case .finished:
            QuizFinishedView(
                score: viewModel.score,
                maxStreak: viewModel.maxStreak,
                totalQuestions: viewModel.questions.count,
                onPlayAgain: {
                    viewModel.resetQuiz()
                    Task {
                        await viewModel.loadQuestions()
                    }
                },
                onHome: {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Quiz Header
struct QuizHeaderView: View {
    let onBack: () -> Void
    let score: Int
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.title2)
            }
            
            Spacer()
            
            Text("Quiz Rush")
                .font(.headline)
            
            Spacer()
            
            QuizScoreView(score: score)
        }
        .padding()
    }
}

// MARK: - Quiz Question View
struct QuizQuestionView: View {
    let question: Question
    let currentIndex: Int
    let totalQuestions: Int
    let streak: Int
    let selectedAnswer: String?
    let answerState: AnswerState
    let isAnswering: Bool
    let onAnswerSelected: (String) -> Void
    
    @State private var isQuestionVisible = false
    @State private var isOptionsVisible = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress
                QuestionProgressView(
                    current: currentIndex,
                    total: totalQuestions,
                    streak: streak
                )
                .padding(.horizontal)
                
                // Question Card
                VStack(spacing: 16) {
                    // Category Badge
                    Text(question.category.decodedHTML)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Difficulty Badge
                    Text(question.difficulty.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(difficultyColor.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(difficultyColor)
                    
                    // Question Text
                    Text(question.question.decodedHTML)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                        .opacity(isQuestionVisible ? 1 : 0)
                        .offset(y: isQuestionVisible ? 0 : 20)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                
                // Answer Options
                VStack(spacing: 12) {
                    ForEach(question.allAnswers, id: \.self) { answer in
                        AnswerButton(
                            text: answer.decodedHTML,
                            isSelected: selectedAnswer == answer,
                            state: selectedAnswer == answer ? answerState : .none
                        ) {
                            if !isAnswering {
                                onAnswerSelected(answer)
                            }
                        }
                        .opacity(isOptionsVisible ? 1 : 0)
                        .offset(x: isOptionsVisible ? 0 : -20)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            // Animate question appearance
            withAnimation(.easeOut(duration: 0.5)) {
                isQuestionVisible = true
            }
            // Animate options with staggered delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isOptionsVisible = true
                }
            }
        }
        .onChange(of: currentIndex) { _ in
            // Reset animations when question changes
            isQuestionVisible = false
            isOptionsVisible = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isQuestionVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isOptionsVisible = true
                    }
                }
            }
        }
    }
    
    private var difficultyColor: Color {
        switch question.difficulty {
        case "easy":
            return .green
        case "medium":
            return .orange
        default:
            return .red
        }
    }
}

//
//  QuizComponents.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//


import SwiftUI
import CoreLocation

struct QuizRushView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = QuizRushVM()
    @State private var hasRecordedSession = false
    
    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.state {
            case .idle, .loading:
                QuizLoadingView()
            case .loaded:
                quizContent
            case .finished:
                QuizFinishedView(
                    score: viewModel.score,
                    maxStreak: viewModel.streak,
                    totalQuestions: viewModel.questions.count,
                    onPlayAgain: { Task { await startQuiz() } },
                    onHome: { dismiss() }
                )
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.state == .idle {
                await startQuiz()
            }
        }
        .onChange(of: viewModel.state) { _, state in
            if state == .finished {
                recordSessionIfNeeded()
            }
        }
    }
    
    @ViewBuilder
    private var quizContent: some View {
        if let question = viewModel.currentQuestion {
            VStack(spacing: 24) {
                QuestionProgressView(
                    current: viewModel.currentIndex,
                    total: viewModel.questions.count,
                    streak: viewModel.streak
                )
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Text(question.category.decodedHTML)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(question.question.decodedHTML)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(question.allAnswers, id: \.self) { answer in
                        AnswerButton(
                            text: answer.decodedHTML,
                            isSelected: viewModel.selectedAnswer == answer,
                            state: answerState(for: answer, question: question),
                            isDisabled: viewModel.isAnswering,
                            action: { viewModel.selectAnswer(answer) }
                        )
                    }
                }
                .padding(.horizontal)
                
                if viewModel.showFeedback {
                    Text(viewModel.feedbackMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        } else {
            QuizLoadingView()
        }
    }
    
    private func answerState(for answer: String, question: Question) -> AnswerState {
        guard viewModel.isAnswering else { return .none }
        if answer == question.correct_answer {
            return .correct
        }
        if answer == viewModel.selectedAnswer {
            return .wrong
        }
        return .none
    }
    
    private func startQuiz() async {
        hasRecordedSession = false
        await viewModel.loadQuestions()
    }
    
    private func recordSessionIfNeeded() {
        guard !hasRecordedSession else { return }
        hasRecordedSession = true
        
        let session = GameSession(
            mode: .quizRush,
            score: viewModel.score,
            latitude: locationService.currentLocation?.coordinate.latitude,
            longitude: locationService.currentLocation?.coordinate.longitude
        )
        statsVM.addSession(session)
    }
}

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


// MARK: - Loading View
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

// MARK: - Error View
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

// MARK: - Finished View
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

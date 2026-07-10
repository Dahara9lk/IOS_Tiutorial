//
//  QuizRushView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.


import SwiftUI
import CoreLocation

struct QuizRushView: View {
    // Environment
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = QuizRushVM() // here this was QuizModel() beacause changed in the ViewModels Folder
    //Storage of the App
    @AppStorage("quizRushHighScore") private var highScore = 0
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isRecordingSession = false
        
    
    //Body
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
                    
                    // Score
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(viewModel.score)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.purple.opacity(0.1)))
                }
                .padding()
                
                // Content
                contentView
            }
            .task {
                await viewModel.loadQuestions()
            }
            .onChange(of: viewModel.state) { oldState, newState in
                // Record session when quiz finishes
                if newState == .finished && !isRecordingSession {
                    isRecordingSession = true
                    
                    // Update high score
                    if viewModel.score > highScore {
                        highScore = viewModel.score
                    }
                    
                    // Record session
                    let session = GameSession(
                        mode: .quizRush,
                        score: viewModel.score,
                        latitude: locationService.currentLocation?.coordinate.latitude,
                        longitude: locationService.currentLocation?.coordinate.longitude
                    )
                    statsVM.addSession(session)
                    print("🏆 Quiz Rush session recorded: \(viewModel.score)")
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
                Text(errorMessage)
            }
        }
        
        // MARK: - Content View
        @ViewBuilder
        private var contentView: some View {
            switch viewModel.state {
            case .idle:
                VStack {
                    Spacer()
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    Text("Ready for Quiz?")
                        .font(.title2)
                        .padding()
                    Button("Start Quiz") {
                        Task {
                            await viewModel.loadQuestions()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .padding()
                    Spacer()
                }
                
            case .loading:
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading Questions...")
                        .padding()
                    Text("Fetching from Open Trivia DB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
            case .loaded:
                if let question = viewModel.currentQuestion {
                    QuizQuestionView(
                        question: question,
                        viewModel: viewModel
                    )
                } else {
                    Text("No question available")
                        .foregroundColor(.secondary)
                }
                
            case .finished:
                // Show ResultView with ShareLink
                ResultView(
                    score: viewModel.score,
                    mode: .quizRush,
                    onPlayAgain: {
                        isRecordingSession = false
                        viewModel.reset()
                        Task {
                            await viewModel.loadQuestions()
                        }
                    },
                    onHome: { dismiss() }
                )
            }
        }
    }

    // MARK: - Quiz Question View
    struct QuizQuestionView: View {
        let question: Question
        @ObservedObject var viewModel: QuizRushVM
        
        @State private var isQuestionVisible = false
        @State private var isOptionsVisible = false
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress
                    HStack {
                        Text("Question \(viewModel.currentIndex + 1) of 10")
                            .font(.headline)
                        Spacer()
                        if viewModel.streak > 0 {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(viewModel.streak)")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Question Card
                    VStack(alignment: .leading, spacing: 12) {
                        // Category
                        Text(question.category.decodedHTML)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                        
                        // Difficulty
                        Text(question.difficulty.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(difficultyColor.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(difficultyColor)
                        
                        // Question
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
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    
                    // Answers
                    VStack(spacing: 12) {
                        ForEach(question.allAnswers, id: \.self) { answer in
                            Button(action: {
                                if !viewModel.isAnswering {
                                    viewModel.selectAnswer(answer)
                                }
                            }) {
                                Text(answer.decodedHTML)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(buttonColor(for: answer))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(buttonBorder(for: answer), lineWidth: 2)
                                    )
                            }
                            .disabled(viewModel.isAnswering)
                            .opacity(isOptionsVisible ? 1 : 0)
                            .offset(x: isOptionsVisible ? 0 : -20)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Feedback Message
                    if viewModel.showFeedback {
                        VStack {
                            Text(viewModel.feedbackMessage)
                                .font(.headline)
                                .foregroundColor(viewModel.answerState == .correct ? .green : .red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    viewModel.answerState == .correct ?
                                        Color.green.opacity(0.1) :
                                        Color.red.opacity(0.1)
                                )
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .onAppear {
                animateContent()
            }
            .onChange(of: viewModel.currentIndex) { oldIndex, newIndex in
                animateContent()
            }
        }
        
        // MARK: - Helper Functions
        private func animateContent() {
            isQuestionVisible = false
            isOptionsVisible = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isQuestionVisible = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isOptionsVisible = true
                }
            }
        }
        
        private var difficultyColor: Color {
            switch question.difficulty {
            case "easy": return .green
            case "medium": return .orange
            default: return .red
            }
        }
        
        private func buttonColor(for answer: String) -> Color {
            if viewModel.isAnswering {
                if answer == question.correct_answer {
                    return Color.green.opacity(0.3)
                }
                if viewModel.selectedAnswer == answer && viewModel.answerState == .wrong {
                    return Color.red.opacity(0.3)
                }
            }
            
            if viewModel.selectedAnswer == answer {
                if viewModel.answerState == .correct {
                    return Color.green.opacity(0.3)
                } else if viewModel.answerState == .wrong {
                    return Color.red.opacity(0.3)
                }
                return Color.purple.opacity(0.2)
            }
            return Color.gray.opacity(0.1)
        }
        
        private func buttonBorder(for answer: String) -> Color {
            if viewModel.isAnswering {
                if answer == question.correct_answer {
                    return .green
                }
                if viewModel.selectedAnswer == answer && viewModel.answerState == .wrong {
                    return .red
                }
            }
            
            if viewModel.selectedAnswer == answer {
                if viewModel.answerState == .correct {
                    return .green
                } else if viewModel.answerState == .wrong {
                    return .red
                }
                return .purple
            }
            return Color.clear
        }
    }

    #Preview {
        QuizRushView()
            .environmentObject(StatsViewModel())
            .environmentObject(LocationService())
    }

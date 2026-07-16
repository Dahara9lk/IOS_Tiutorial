//
//  QuizRushView.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-07-10.
//

import SwiftUI
import CoreLocation

// MARK: - Trivia Category Model
struct TriviaCategory: Identifiable {
    let id: Int
    let name: String
}

// MARK: - QuizRushView (ONLY the View - NO ViewModel Declaration)
struct QuizRushView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = QuizRushVM()  // ✅ Uses QuizRushVM from separate file
    @State private var hasRecordedSession = false
    @State private var showCategorySelection = true
    @State private var selectedCategoryName = "Random"
    
    let categories: [TriviaCategory] = [
        TriviaCategory(id: 9, name: "General Knowledge"),
        TriviaCategory(id: 10, name: "Books"),
        TriviaCategory(id: 11, name: "Film"),
        TriviaCategory(id: 12, name: "Music"),
        TriviaCategory(id: 13, name: "Musicals & Theatre"),
        TriviaCategory(id: 14, name: "Television"),
        TriviaCategory(id: 15, name: "Video Games"),
        TriviaCategory(id: 16, name: "Board Games"),
        TriviaCategory(id: 17, name: "Science & Nature"),
        TriviaCategory(id: 18, name: "Computers"),
        TriviaCategory(id: 19, name: "Mathematics"),
        TriviaCategory(id: 20, name: "Mythology"),
        TriviaCategory(id: 21, name: "Sports"),
        TriviaCategory(id: 22, name: "Geography"),
        TriviaCategory(id: 23, name: "History"),
        TriviaCategory(id: 24, name: "Politics"),
        TriviaCategory(id: 25, name: "Art"),
        TriviaCategory(id: 26, name: "Celebrities"),
        TriviaCategory(id: 27, name: "Animals"),
        TriviaCategory(id: 28, name: "Vehicles"),
        TriviaCategory(id: 29, name: "Comics"),
        TriviaCategory(id: 30, name: "Gadgets"),
        TriviaCategory(id: 31, name: "Anime & Manga"),
        TriviaCategory(id: 32, name: "Cartoons"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                
                Text("Quiz Rush")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.purple.opacity(0.1)))
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            // Level & Category Info
            if viewModel.state == .loaded && !showCategorySelection {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(viewModel.currentLevel.color)
                            .font(.caption)
                        Text("Level \(viewModel.currentLevel.rawValue)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.currentLevel.color)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(viewModel.currentLevel.color.opacity(0.15))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("Category: \(selectedCategoryName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            
            // Content
            Group {
                if showCategorySelection && viewModel.state != .finished {
                    CategorySelectionView(
                        categories: categories,
                        onCategorySelected: { categoryID, categoryName in
                            selectedCategoryName = categoryName ?? "Random"
                            showCategorySelection = false
                            Task {
                                await viewModel.loadQuestions(categoryID: categoryID)
                            }
                        }
                    )
                } else {
                    switch viewModel.state {
                    case .idle:
                        Color.clear
                    case .loading:
                        QuizLoadingView()
                    case .loaded:
                        if viewModel.questions.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                Text("No questions available")
                                    .font(.headline)
                                Text("Try selecting a different category")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Button("Go Back") {
                                    showCategorySelection = true
                                    viewModel.reset()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.purple)
                            }
                        } else if let question = viewModel.currentQuestion {
                            QuizQuestionView(
                                question: question,
                                viewModel: viewModel
                            )
                            .id(question.id)
                        }
                    case .finished:
                        QuizFinishedView(
                            score: viewModel.score,
                            maxStreak: viewModel.streak,
                            totalQuestions: viewModel.questions.count,
                            onPlayAgain: {
                                hasRecordedSession = false
                                showCategorySelection = true
                                viewModel.reset()
                            },
                            onHome: { dismiss() }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(false)
        .onChange(of: viewModel.state) { _, state in
            if state == .finished {
                recordSessionIfNeeded()
            }
        }
        .alert("Level Up! 🎉", isPresented: $viewModel.showLevelUp) {
            Button("Continue") {
                viewModel.showLevelUp = false
            }
        } message: {
            Text(viewModel.levelUpMessage)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("Retry") {
                Task {
                    await viewModel.loadQuestions(categoryID: viewModel.selectedCategoryID)
                }
            }
            Button("Cancel", role: .cancel) {
                showCategorySelection = true
                viewModel.reset()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
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
        print("🏆 Quiz Rush session recorded: \(viewModel.score)")
    }
}

// MARK: - Category Selection View
struct CategorySelectionView: View {
    let categories: [TriviaCategory]
    let onCategorySelected: (Int?, String?) -> Void
    
    @State private var selectedCategory: Int?
    @State private var selectedCategoryName: String?
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                Text("Choose a Category")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Select a topic for your quiz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Divider()
                .padding(.horizontal)
            
            // Category Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    // Random Category Button
                    CategoryButton(
                        title: "🎲 Random",
                        subtitle: "Surprise me!",
                        isSelected: selectedCategory == nil,
                        color: .purple
                    ) {
                        selectedCategory = nil
                        selectedCategoryName = nil
                        onCategorySelected(nil, "Random")
                    }
                    
                    // Predefined Categories
                    ForEach(categories) { category in
                        CategoryButton(
                            title: category.name,
                            subtitle: "",
                            isSelected: selectedCategory == category.id,
                            color: categoryColor(for: category.id)
                        ) {
                            selectedCategory = category.id
                            selectedCategoryName = category.name
                            onCategorySelected(category.id, category.name)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
    
    private func categoryColor(for id: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .red, .teal, .indigo, .mint, .cyan, .yellow, .brown]
        return colors[id % colors.count]
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? color : color.opacity(0.12))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isHovered && !isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
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
        VStack(spacing: 16) {
            // Progress
            HStack {
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.totalQuestions)")
                    .font(.headline)
                Spacer()
                if viewModel.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(viewModel.streak)")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            
            // Level Badge
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: viewModel.currentLevel.icon)
                        .foregroundColor(viewModel.currentLevel.color)
                        .font(.caption)
                    Text(viewModel.currentLevel.difficultyString)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.currentLevel.color)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(viewModel.currentLevel.color.opacity(0.15))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // Question Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(question.category.decodedHTML)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(question.difficulty.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(difficultyColor.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(difficultyColor)
                }
                
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
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            
            // Answers
            VStack(spacing: 12) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    AnswerButton(
                        text: answer.decodedHTML,
                        isSelected: viewModel.selectedAnswer == answer,
                        state: getAnswerState(for: answer),
                        isDisabled: viewModel.isAnswering || viewModel.showFeedback
                    ) {
                        if !viewModel.isAnswering && !viewModel.showFeedback {
                            viewModel.selectAnswer(answer)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .opacity(isOptionsVisible ? 1 : 0)
            .offset(x: isOptionsVisible ? 0 : -20)
            
            // Feedback
            if viewModel.showFeedback {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: viewModel.answerState == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(viewModel.answerState == .correct ? .green : .red)
                        
                        Text(viewModel.feedbackMessage)
                            .font(.headline)
                            .foregroundColor(viewModel.answerState == .correct ? .green : .red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        viewModel.answerState == .correct ?
                            Color.green.opacity(0.1) :
                            Color.red.opacity(0.1)
                    )
                    .cornerRadius(12)
                    
                    if viewModel.answerState == .wrong {
                        Text("Correct Answer: \(question.correct_answer.decodedHTML)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .transition(.opacity)
            }
            
            // Level Progress Bar
            VStack(spacing: 4) {
                HStack {
                    Text("Level Progress")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.currentIndex + 1)/\(viewModel.totalQuestions)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: levelGradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.levelProgress, height: 4)
                            .cornerRadius(2)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.levelProgress)
                    }
                }
                .frame(height: 4)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
        .onAppear {
            animateContent()
        }
        .onChange(of: viewModel.currentIndex) { _, _ in
            animateContent()
        }
    }
    
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
    
    private var levelGradientColors: [Color] {
        switch viewModel.currentLevel {
        case .easy:
            return [.green, .green.opacity(0.5)]
        case .medium:
            return [.orange, .orange.opacity(0.5)]
        case .hard:
            return [.red, .red.opacity(0.5)]
        }
    }
    
    private func getAnswerState(for answer: String) -> AnswerState {
        if viewModel.isAnswering || viewModel.showFeedback {
            if answer == question.correct_answer {
                return .correct
            }
            if viewModel.selectedAnswer == answer && viewModel.answerState == .wrong {
                return .wrong
            }
        }
        
        if viewModel.selectedAnswer == answer && !viewModel.showFeedback {
            return viewModel.answerState
        }
        return .none
    }
}

// MARK: - Quiz Loading View
struct QuizLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Questions...")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Fetching from Open Trivia DB")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

#Preview {
    NavigationStack {
        QuizRushView()
            .environmentObject(StatsViewModel())
            .environmentObject(LocationService())
    }
}

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

// MARK: - QuizRushView
struct QuizRushView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var statsVM: StatsViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = QuizRushVM()
    @State private var hasRecordedSession = false
    @State private var showCategorySelection = true
    @State private var selectedCategoryName = "Random"
    @State private var showPopup = false
    @State private var popupMessage = ""
    @State private var popupColor = Color.green
    @State private var correctAnswerText = ""
    
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
        ZStack {
            LinearGradient.mainGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Text("⚡ QUIZ RUSH")
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.black)
                        .foregroundColor(.cyan)
                        .shadow(color: .cyan.opacity(0.8), radius: 8)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow, radius: 4)
                        Text("\(viewModel.score)")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.5), radius: 6)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                Capsule()
                                    .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                                    .shadow(color: .yellow, radius: 2)
                            )
                    )
                }
                .padding()
                
                Divider()
                    .background(Color.purple.opacity(0.3))
                
                if viewModel.state == .loaded && !showCategorySelection {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(viewModel.currentLevel.color)
                                .font(.caption)
                                .shadow(color: viewModel.currentLevel.color.opacity(0.5), radius: 3)
                            Text("LEVEL \(viewModel.currentLevel.rawValue)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    Capsule()
                                        .stroke(viewModel.currentLevel.color, lineWidth: 2)
                                        .shadow(color: viewModel.currentLevel.color, radius: 3)
                                )
                        )
                        
                        Spacer()
                        
                        Text("🎯 \(selectedCategoryName)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
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
                                        .foregroundColor(.white)
                                    Text("Try selecting a different category")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Button("Go Back") {
                                        showCategorySelection = true
                                        viewModel.reset()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.purple)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                QuizQuestionView(
                                    question: viewModel.currentQuestion!,
                                    viewModel: viewModel,
                                    showPopup: $showPopup,
                                    popupMessage: $popupMessage,
                                    popupColor: $popupColor,
                                    correctAnswerText: $correctAnswerText
                                )
                                .id(viewModel.currentIndex)
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if !showCategorySelection {
                        showCategorySelection = true
                        viewModel.reset()
                    } else {
                        dismiss()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                        Text("Back")
                    }
                }
            }
        }
        .onChange(of: viewModel.state) { oldState, newState in
            if newState == .finished {
                recordSessionIfNeeded()
            }
        }
        .alert("🎉 Level Up!", isPresented: $viewModel.showLevelUp) {
            Button("Continue!") {
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
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                    .shadow(color: .purple.opacity(0.5), radius: 15)
                
                Text("SELECT CATEGORY")
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.black)
                    .foregroundColor(.cyan)
                    .shadow(color: .cyan.opacity(0.8), radius: 8)
                
                Text("Choose your battle ground!")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            
            Divider()
                .background(Color.purple.opacity(0.3))
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    GameCategoryButton(
                        title: "🎲 Random",
                        subtitle: "Surprise me!",
                        isSelected: selectedCategory == nil,
                        color: .purple
                    ) {
                        selectedCategory = nil
                        selectedCategoryName = nil
                        onCategorySelected(nil, "Random")
                    }
                    
                    ForEach(categories) { category in
                        GameCategoryButton(
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
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.clear)
    }
    
    private func categoryColor(for id: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .red, .teal, .indigo, .mint, .cyan, .yellow, .brown]
        return colors[id % colors.count]
    }
}

// MARK: - Game Category Button
struct GameCategoryButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .buttonStyle(CategoryButtonStyle(isSelected: isSelected, color: color))
    }
}

struct CategoryButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.3) : (configuration.isPressed ? color.opacity(0.15) : Color.white.opacity(0.03)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? color : (configuration.isPressed ? color.opacity(0.5) : Color.white.opacity(0.05)), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : (isSelected ? 1.03 : 1.0))
            .shadow(
                color: configuration.isPressed || isSelected ? color.opacity(0.3) : .clear,
                radius: configuration.isPressed || isSelected ? 10 : 0
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Quiz Question View
struct QuizQuestionView: View {
    let question: Question
    @ObservedObject var viewModel: QuizRushVM
    @Binding var showPopup: Bool
    @Binding var popupMessage: String
    @Binding var popupColor: Color
    @Binding var correctAnswerText: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress
                HStack {
                    Text("Question \(viewModel.currentIndex + 1)")
                        .font(.system(.headline, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    if viewModel.streak > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.5), radius: 5)
                            Text("\(viewModel.streak)x")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("/ \(viewModel.totalQuestions)")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal)
                
                // Question Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(question.category.decodedHTML)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.purple.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.purple)
                        
                        Text(question.difficulty.capitalized)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(difficultyColor.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(difficultyColor.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(difficultyColor)
                    }
                    
                    Text(question.question.decodedHTML)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                        )
                )
                .shadow(color: .cyan.opacity(0.3), radius: 15)
                .padding(.horizontal)
                
                // Answer Buttons
                VStack(spacing: 12) {
                    ForEach(question.allAnswers, id: \.self) { answer in
                        GameAnswerButton(
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
                
                // Feedback with Correct Answer
                if viewModel.showFeedback {
                    VStack(spacing: 12) {
                        if viewModel.answerState == .correct {
                            // ✅ Correct feedback
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                Text("✅ CORRECT! +2 POINTS")
                                    .font(.system(.headline, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.green.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        } else {
                            // ❌ Wrong feedback
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                Text("❌ WRONG! -1 POINT")
                                    .font(.system(.headline, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // ✅ ALWAYS SHOW CORRECT ANSWER
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 5)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Correct Answer:")
                                    .font(.system(.caption, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                                Text(question.correct_answer.decodedHTML)
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .shadow(color: .green.opacity(0.3), radius: 3)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Level Progress Bar
                VStack(spacing: 4) {
                    HStack {
                        Text("Level Progress")
                            .font(.system(.caption2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.4))
                        Spacer()
                        Text("\(viewModel.currentIndex + 1)/\(viewModel.totalQuestions)")
                            .font(.system(.caption2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: levelGradientColors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * viewModel.levelProgress, height: 6)
                                .cornerRadius(3)
                                .animation(.easeInOut(duration: 0.3), value: viewModel.levelProgress)
                                .shadow(color: viewModel.currentLevel.color.opacity(0.5), radius: 5)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .onChange(of: viewModel.showFeedback) { oldValue, newValue in
            if newValue {
                if viewModel.answerState == .correct {
                    popupMessage = "✅ CORRECT! +2 POINTS"
                    popupColor = .green
                    correctAnswerText = ""
                } else {
                    popupMessage = "❌ WRONG! -1 POINT"
                    popupColor = .red
                    correctAnswerText = question.correct_answer.decodedHTML
                }
                showPopup = true
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

// MARK: - Game Answer Button
struct GameAnswerButton: View {
    let text: String
    let isSelected: Bool
    let state: AnswerState
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    @State private var isPressed = false
    @State private var isFloating = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(foregroundColor)
                
                Spacer()
                
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                        .transition(.scale)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                        .transition(.scale)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(borderColor, lineWidth: state != .none ? 2 : (isHovered ? 2 : 1))
                    )
            )
            .scaleEffect(isHovered && !isDisabled && state == .none ? 1.04 : (isPressed ? 0.96 : (isFloating && state == .none && !isDisabled ? 1.02 : 1.0)))
            .shadow(
                color: (isHovered || isFloating) && !isDisabled && state == .none ? Color.cyan.opacity(0.2) : .clear,
                radius: (isHovered || isFloating) && !isDisabled && state == .none ? 10 : 0
            )
        }
        .disabled(isDisabled || state != .none)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: state)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isFloating = true
            }
        }
    }
    
    private var backgroundColor: Color {
        switch state {
        case .correct:
            return .green
        case .wrong:
            return .red
        default:
            if isSelected {
                return Color.cyan.opacity(0.2)
            }
            return isHovered ? Color.cyan.opacity(0.08) : Color.white.opacity(0.03)
        }
    }
    
    private var foregroundColor: Color {
        switch state {
        case .correct, .wrong:
            return .white
        default:
            return isSelected ? .cyan : .white
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
                return .cyan
            }
            return isHovered ? Color.cyan.opacity(0.4) : Color.white.opacity(0.05)
        }
    }
}

// MARK: - Quiz Loading View
struct QuizLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(.purple)
            Text("LOADING QUESTIONS...")
                .font(.system(.headline, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
            Text("Fetching from Open Trivia DB")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
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
                .font(.system(size: 70))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 20)
            
            Text("🏆 QUIZ COMPLETE!")
                .font(.system(.largeTitle, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Text("SCORE:")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(score)")
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.3), radius: 5)
                }
                
                HStack {
                    Text("BEST STREAK:")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(maxStreak)")
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.3), radius: 5)
                }
                
                Text("\(score)/\(totalQuestions)")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Text("🔄 PLAY AGAIN")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.purple)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .shadow(color: .purple.opacity(0.4), radius: 10)
                }
                .buttonStyle(.plain)
                
                Button(action: onHome) {
                    Text("🏠 HOME")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        QuizRushView()
            .environmentObject(StatsViewModel())
            .environmentObject(LocationService())
    }
}

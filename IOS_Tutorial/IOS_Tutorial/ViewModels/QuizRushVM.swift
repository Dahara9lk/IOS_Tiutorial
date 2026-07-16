//
//  QuizViewModel.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-07-10.
//

import SwiftUI
import Combine

@MainActor
class QuizRushVM: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: QuizState = .idle
    @Published var selectedAnswer: String?
    @Published var answerState: AnswerState = .none
    @Published var isAnswering = false
    @Published var showFeedback = false
    @Published var feedbackMessage = ""
    @Published var showLevelUp = false
    @Published var levelUpMessage = ""
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedCategoryID: Int?
    
    // Level Progression
    @Published var currentLevel: QuizLevel = .easy
    @Published var correctStreak = 0
    
    private let api = TriviaAPI()
    private var workItem: DispatchWorkItem?
    private var isUpdating = false
    
    var totalQuestions: Int {
        questions.count
    }
    
    var levelProgress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalQuestions)
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    func loadQuestions(categoryID: Int? = nil) async {
        print("🟣 loadQuestions called with categoryID: \(categoryID?.description ?? "nil")")
        selectedCategoryID = categoryID
        currentLevel = .easy
        correctStreak = 0
        
        await MainActor.run {
            state = .loading
            questions = []
            currentIndex = 0
            score = 0
            streak = 0
            selectedAnswer = nil
            answerState = .none
            isAnswering = false
            showFeedback = false
            feedbackMessage = ""
            showLevelUp = false
            levelUpMessage = ""
            showError = false
            errorMessage = ""
        }
        
        do {
            print("🟣 Fetching questions from API for category: \(categoryID?.description ?? "Random")")
            let fetched = try await api.fetchQuestions(categoryID: categoryID)
            print("🟣 API returned \(fetched.count) questions")
            
            let sortedQuestions = sortQuestionsByDifficulty(fetched)
            
            await MainActor.run {
                if sortedQuestions.isEmpty {
                    state = .idle
                    showError = true
                    errorMessage = "No questions available for this category. Please try another."
                } else {
                    questions = sortedQuestions
                    state = .loaded
                    print("✅ Loaded \(sortedQuestions.count) questions")
                    print("✅ First question: \(sortedQuestions.first?.question.prefix(50) ?? "nil")")
                }
            }
        } catch {
            print("❌ API Error: \(error.localizedDescription)")
            await MainActor.run {
                showError = true
                errorMessage = "Failed to load questions: \(error.localizedDescription)"
                state = .idle
            }
        }
    }
    
    private func sortQuestionsByDifficulty(_ questions: [Question]) -> [Question] {
        let difficultyOrder: [String: Int] = ["easy": 0, "medium": 1, "hard": 2]
        return questions.sorted {
            (difficultyOrder[$0.difficulty] ?? 0) < (difficultyOrder[$1.difficulty] ?? 0)
        }
    }
    
    func selectAnswer(_ answer: String) {
        guard !isUpdating, !isAnswering, let question = currentQuestion else { return }
        
        isUpdating = true
        isAnswering = true
        selectedAnswer = answer
        
        if answer == question.correct_answer {
            answerState = .correct
            let bonusPoints = 2
            streak += 1
            correctStreak += 1
            score += bonusPoints + (streak >= 3 ? 1 : 0)
            feedbackMessage = "✅ Correct! +\(bonusPoints) points \(streak >= 3 ? "🔥 Streak: \(streak)!" : "")"
        } else {
            answerState = .wrong
            score = max(0, score - 1)
            streak = 0
            correctStreak = 0
            feedbackMessage = "❌ Wrong! Correct answer: \(question.correct_answer.decodedHTML)"
        }
        
        showFeedback = true
        
        if correctStreak >= 3 {
            checkLevelUp()
        }
        
        workItem?.cancel()
        
        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.showFeedback = false
                self.feedbackMessage = ""
                self.isAnswering = false
                self.isUpdating = false
                
                if self.currentIndex < self.questions.count - 1 {
                    self.currentIndex += 1
                    self.selectedAnswer = nil
                    self.answerState = .none
                } else {
                    self.state = .finished
                }
            }
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: item)
    }
    
    private func checkLevelUp() {
        guard !questions.isEmpty else { return }
        
        let progress = Double(currentIndex + 1) / Double(questions.count)
        
        let newLevel: QuizLevel
        if progress <= 0.33 {
            newLevel = .easy
        } else if progress <= 0.66 {
            newLevel = .medium
        } else {
            newLevel = .hard
        }
        
        if newLevel != currentLevel {
            let oldLevel = currentLevel
            currentLevel = newLevel
            showLevelUp = true
            levelUpMessage = "🎉 Level Up! You reached \(newLevel.difficultyString) level!"
            correctStreak = 0
            print("⬆️ Level up: \(oldLevel.difficultyString) → \(newLevel.difficultyString)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showLevelUp = false
            }
        }
    }
    
    func reset() {
        workItem?.cancel()
        isUpdating = false
        
        questions = []
        currentIndex = 0
        score = 0
        streak = 0
        state = .idle
        selectedAnswer = nil
        answerState = .none
        isAnswering = false
        showFeedback = false
        feedbackMessage = ""
        currentLevel = .easy
        showLevelUp = false
        levelUpMessage = ""
        showError = false
        errorMessage = ""
        selectedCategoryID = nil
        correctStreak = 0
    }
}

// MARK: - Quiz Level Enum
enum QuizLevel: Int, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3
    
    var difficultyString: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "star.fill"
        case .medium: return "star.leadinghalf.filled"
        case .hard: return "star"
        }
    }
}

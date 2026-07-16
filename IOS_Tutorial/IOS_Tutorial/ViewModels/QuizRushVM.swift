//
//  QuizViewModel.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
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
        selectedCategoryID = categoryID
        currentLevel = .easy
        
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
            showError = false
            errorMessage = ""
        }
        
        do {
            print("🟣 Fetching questions from API for category: \(categoryID?.description ?? "Random")")
            let fetched = try await api.fetchQuestions(categoryID: categoryID)
            print("🟣 API returned \(fetched.count) questions")
            
            // Sort questions by difficulty for level progression
            let sortedQuestions = sortQuestionsByDifficulty(fetched)
            
            await MainActor.run {
                if sortedQuestions.isEmpty {
                    state = .idle
                    showError = true
                    errorMessage = "No questions available for this category. Please try another."
                    print("❌ No questions returned from API")
                } else {
                    questions = sortedQuestions
                    state = .loaded
                    print("✅ Loaded \(sortedQuestions.count) questions from API sorted by difficulty")
                    
                    // Print question difficulties for debugging
                    for (index, q) in sortedQuestions.enumerated() {
                        print("   Question \(index + 1): \(q.difficulty) - \(q.category)")
                    }
                }
            }
        } catch {
            print("❌ API Error: \(error.localizedDescription)")
            await MainActor.run {
                showError = true
                errorMessage = "Failed to load questions: \(error.localizedDescription)\nPlease check your internet connection and try again."
                state = .idle
            }
        }
    }
    
    // Sort questions by difficulty for level progression
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
        
        let levelPoints = currentLevel == .hard ? 3 : currentLevel == .medium ? 2 : 1
        
        if answer == question.correct_answer {
            answerState = .correct
            feedbackMessage = "✅ Correct! +\(levelPoints) points"
            streak += 1
            let bonus = streak >= 3 ? 2 : (streak >= 2 ? 1 : 0)
            score += levelPoints + bonus
        } else {
            answerState = .wrong
            feedbackMessage = "❌ Wrong!"
            streak = 0
        }
        
        showFeedback = true
        
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
                    self.checkLevelUp()
                } else {
                    self.state = .finished
                }
            }
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: item)
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
            levelUpMessage = "You reached \(newLevel.difficultyString) level! 🎉\nQuestions will now be harder!"
            print("⬆️ Level up: \(oldLevel.difficultyString) → \(newLevel.difficultyString)")
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

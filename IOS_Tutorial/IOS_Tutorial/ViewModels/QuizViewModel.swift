//
//  QuizViewModel.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//



import SwiftUI
import Combine


// MARK: - Quiz ViewModel
// Handles all quiz logic - separate from the view
class QuizViewModel: ObservableObject {
    // MARK: - Published Properties
    // These trigger UI updates when changed
    @Published var questions: [Question] = []      // All fetched questions
    @Published var currentIndex = 0                // Current question index
    @Published var score = 0                       // User's score
    @Published var streak = 0                      // Current correct streak
    @Published var maxStreak = 0                   // Best streak in this round
    @Published var viewState: QuizViewState = .idle  // Current view state
    @Published var selectedAnswer: String?         // User's selected answer
    @Published var answerState: AnswerState = .none  // Correct/wrong state
    @Published var isAnswering = false             // Prevent double taps
    @Published var showFeedback = false            // Show feedback after answer
    
    // MARK: - Private Properties
    private let quizService = QuizService()
    
    // MARK: - Computed Properties
    // Current question (safe access)
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    // Progress text (e.g., "3 of 10")
    var progressText: String {
        "\(currentIndex + 1) / \(questions.count)"
    }
    
    // Check if it's the last question
    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }
    
    // Check if quiz is finished
    var shouldShowFinished: Bool {
        viewState == .finished || (!questions.isEmpty && currentIndex >= questions.count)
    }
    
    // MARK: - Public Methods
    
    // Load questions from API
    @MainActor
    func loadQuestions() async {
        // Reset everything
        viewState = .loading
        questions = []
        currentIndex = 0
        score = 0
        streak = 0
        maxStreak = 0
        selectedAnswer = nil
        answerState = .none
        isAnswering = false
        showFeedback = false
        
        do {
            // Fetch from API
            let fetchedQuestions = try await quizService.fetchQuestions()
            
            // Update on main thread
            await MainActor.run {
                self.questions = fetchedQuestions
                self.viewState = .loaded
                print("✅ Questions loaded successfully")
            }
        } catch {
            // Handle error
            await MainActor.run {
                self.viewState = .failed(error)
                print("❌ Failed to load questions: \(error)")
            }
        }
    }
    
    // Handle user selecting an answer
    func selectAnswer(_ answer: String) {
        // Prevent multiple selections
        guard !isAnswering,
              let question = currentQuestion,
              viewState == .loaded else { return }
        
        isAnswering = true
        selectedAnswer = answer
        
        // Check if answer is correct
        let isCorrect = answer == question.correct_answer
        
        if isCorrect {
            // ✅ Correct answer
            answerState = .correct
            streak += 1  // Increase streak
            
            // Track best streak
            if streak > maxStreak {
                maxStreak = streak
            }
            
            // Bonus points for streaks
            // 3+ in a row = +2 bonus, 2 in a row = +1 bonus
            let bonus = streak >= 3 ? 2 : (streak >= 2 ? 1 : 0)
            score += 1 + bonus
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        } else {
            // ❌ Wrong answer
            answerState = .wrong
            streak = 0  // Reset streak
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        showFeedback = true
        
        // Advance to next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.advanceToNextQuestion()
        }
    }
    
    // Move to next question or finish
    func advanceToNextQuestion() {
        showFeedback = false
        selectedAnswer = nil
        answerState = .none
        isAnswering = false
        
        if isLastQuestion {
            // Quiz finished
            viewState = .finished
        } else {
            // Move to next question
            currentIndex += 1
        }
    }
    
    // Reset quiz state
    func resetQuiz() {
        questions = []
        currentIndex = 0
        score = 0
        streak = 0
        maxStreak = 0
        viewState = .idle
        selectedAnswer = nil
        answerState = .none
        isAnswering = false
        showFeedback = false
    }
    
    // Retry after error
    func retry() {
        resetQuiz()
        // Will reload on appear
    }
}

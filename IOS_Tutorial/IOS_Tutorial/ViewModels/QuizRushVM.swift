//
//  QuizViewModel.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//

import SwiftUI
import Combine

@MainActor  // ✅ Added - ensures all UI updates happen on main thread
class QuizRushVM: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var state: QuizState = .idle
    @Published var selectedAnswer: String?
    @Published var answerState: AnswerState = .none
    @Published var isAnswering = false
    @Published var showFeedback = false  // ✅ Added - needed for UI feedback
    @Published var feedbackMessage = ""  // ✅ Added - needed for UI feedback
    
    private let service = QuizService()
    private var workItem: DispatchWorkItem?  // ✅ Added - to cancel delayed tasks
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    // ✅ Fixed - use stored properties instead of computed
    // Removed: var showFeedback { answerState != .none }
    // Removed: var feedbackMessage { ... }
    
    @MainActor
    func loadQuestions(categoryID: Int? = nil) async {
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
        
        do {
            let fetched = try await service.fetchQuestions(categoryID: categoryID)
            questions = fetched
            state = .loaded
            print("✅ Loaded \(fetched.count) questions")
        } catch {
            print("❌ Error: \(error)")
            questions = getFallbackQuestions()
            state = .loaded
        }
    }
    
    func getFallbackQuestions() -> [Question] {
        return [
            Question(category: "General", type: "multiple", difficulty: "easy",
                    question: "What is the capital of France?",
                    correct_answer: "Paris",
                    incorrect_answers: ["London", "Berlin", "Madrid"]),
            Question(category: "Science", type: "multiple", difficulty: "easy",
                    question: "What is H2O?",
                    correct_answer: "Water",
                    incorrect_answers: ["Salt", "Sugar", "Air"]),
            Question(category: "History", type: "multiple", difficulty: "easy",
                    question: "Who painted the Mona Lisa?",
                    correct_answer: "Leonardo da Vinci",
                    incorrect_answers: ["Michelangelo", "Raphael", "Donatello"]),
            Question(category: "Geography", type: "multiple", difficulty: "easy",
                    question: "Which is the largest ocean?",
                    correct_answer: "Pacific",
                    incorrect_answers: ["Atlantic", "Indian", "Arctic"]),
            Question(category: "Science", type: "multiple", difficulty: "easy",
                    question: "What planet is known as the Red Planet?",
                    correct_answer: "Mars",
                    incorrect_answers: ["Venus", "Jupiter", "Saturn"]),
            Question(category: "Sports", type: "multiple", difficulty: "easy",
                    question: "Which sport uses a shuttlecock?",
                    correct_answer: "Badminton",
                    incorrect_answers: ["Tennis", "Cricket", "Golf"]),
            Question(category: "Entertainment", type: "multiple", difficulty: "easy",
                    question: "Who played Iron Man?",
                    correct_answer: "Robert Downey Jr.",
                    incorrect_answers: ["Chris Evans", "Chris Hemsworth", "Scarlett Johansson"]),
            Question(category: "Technology", type: "multiple", difficulty: "easy",
                    question: "What does CPU stand for?",
                    correct_answer: "Central Processing Unit",
                    incorrect_answers: ["Computer Personal Unit", "Core Processing Unit", "Central Program Unit"]),
            Question(category: "Geography", type: "multiple", difficulty: "easy",
                    question: "Which country has the most people?",
                    correct_answer: "China",
                    incorrect_answers: ["India", "USA", "Indonesia"]),
            Question(category: "Science", type: "multiple", difficulty: "easy",
                    question: "What is the chemical symbol for gold?",
                    correct_answer: "Au",
                    incorrect_answers: ["Ag", "Fe", "Cu"])
        ]
    }
    
    func selectAnswer(_ answer: String) {
        guard !isAnswering, let question = currentQuestion else { return }
        
        isAnswering = true
        selectedAnswer = answer
        
        if answer == question.correct_answer {
            answerState = .correct
            feedbackMessage = "✅ Correct! \(streak >= 2 ? "Streak: \(streak + 1)!" : "")"
            streak += 1
            let bonus = streak >= 3 ? 2 : (streak >= 2 ? 1 : 0)
            score += 1 + bonus
        } else {
            answerState = .wrong
            feedbackMessage = "❌ Wrong! Correct answer: \(question.correct_answer.decodedHTML)"
            streak = 0
        }
        
        showFeedback = true
        
        // ✅ Cancel any existing work item
        workItem?.cancel()
        
        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.showFeedback = false
            self.feedbackMessage = ""
            
            if self.currentIndex < self.questions.count - 1 {
                self.currentIndex += 1
                self.selectedAnswer = nil
                self.answerState = .none
                self.isAnswering = false
            } else {
                self.state = .finished
            }
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: item)
    }
    
    func reset() {
        workItem?.cancel()
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
    }
}

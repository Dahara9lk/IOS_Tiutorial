//
//  QuizModel.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//


import Foundation

// MARK: - API Response Wrapper
// This matches the JSON structure from Open Trivia DB
struct QuizResponse: Codable {
    let response_code: Int  // 0 = success, 1 = no results, etc.
    let results: [Question]
}

// MARK: - Question Model
// Each question from the API
struct Question: Codable, Identifiable {
    let id = UUID()  // For SwiftUI's ForEach
    let type: String  // "multiple" or "boolean"
    let difficulty: String  // "easy", "medium", "hard"
    let category: String
    let question: String  // The question text (may have HTML entities)
    let correct_answer: String
    let incorrect_answers: [String]
    
    // Combine correct and incorrect answers, then shuffle
    // This gives us all 4 options in random order
    var allAnswers: [String] {
        var answers = incorrect_answers
        answers.append(correct_answer)
        return answers.shuffled()
    }
    
    // Tell Swift how to map JSON keys to our properties
    enum CodingKeys: String, CodingKey {
        case type, difficulty, category, question
        case correct_answer = "correct_answer"
        case incorrect_answers = "incorrect_answers"
    }
}

// MARK: - Quiz State Enum
// Represents the current state of the quiz view
enum QuizViewState {
    case idle           // Not started
    case loading        // Fetching questions
    case loaded         // Ready to play
    case failed(Error)  // Error occurred
    case finished       // Quiz completed
    
    // Helper computed properties
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .failed(let error) = self {
            return error.localizedDescription
        }
        return nil
    }
}

// MARK: - Answer State
// Represents the state of an answer button
enum AnswerState {
    case none      // Default state
    case correct   // User selected correct answer
    case wrong     // User selected wrong answer
}

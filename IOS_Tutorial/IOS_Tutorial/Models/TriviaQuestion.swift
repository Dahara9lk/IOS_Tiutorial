//
//  QuizModel.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//

import Foundation

struct QuizResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    var allAnswers: [String] {
        var answers = incorrect_answers
        answers.append(correct_answer)
        return answers.shuffled()
    }
}

enum QuizState {
    case idle, loading, loaded, finished
}

enum AnswerState {
    case none, correct, wrong
}

//
//  QuizModel.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//

import Foundation

// MARK: - Quiz State Enums
enum QuizState {
    case idle, loading, loaded, finished
}

enum AnswerState {
    case none, correct, wrong
}

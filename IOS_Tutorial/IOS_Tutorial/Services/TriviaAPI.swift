//
//  TriviaAPI.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//

import Foundation

// MARK: - Question Model
struct Question: Identifiable, Codable, Equatable {
    let id = UUID()
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    var allAnswers: [String] {
        (incorrect_answers + [correct_answer]).shuffled()
    }
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correct_answer, incorrect_answers
    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Quiz Response
struct QuizResponse: Codable {
    let response_code: Int
    let results: [Question]
}

// MARK: - Trivia API Service
class TriviaAPI {
    func fetchQuestions(categoryID: Int? = nil) async throws -> [Question] {
        var urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        if let categoryID = categoryID {
            urlString += "&category=\(categoryID)"
        }
        
        guard let url = URL(string: urlString) else {
            throw TriviaAPIError.invalidURL
        }
        
        print("🌐 Fetching from: \(urlString)")
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Print raw response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Raw API Response: \(jsonString.prefix(500))...")
        }
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(QuizResponse.self, from: data)
        
        print("✅ Got \(response.results.count) questions from API")
        print("📊 Response code: \(response.response_code)")
        
        // Check if API returned an error
        if response.response_code != 0 {
            throw TriviaAPIError.apiError("Response code: \(response.response_code)")
        }
        
        return response.results
    }
}

enum TriviaAPIError: Error, LocalizedError {
    case invalidURL
    case decodingError
    case apiError(String)
    case noInternet
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .decodingError:
            return "Failed to decode response"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noInternet:
            return "No internet connection"
        }
    }
}

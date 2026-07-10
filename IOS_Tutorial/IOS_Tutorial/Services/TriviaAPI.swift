//
//  QuizService.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.



import Foundation

enum QuizServiceError: Error {
    case noData
}

class QuizService {
    func fetchQuestions() async throws -> [Question] {
        // Use this URL - it works!
        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        
        guard let url = URL(string: urlString) else {
            throw QuizServiceError.noData
        }
        
        print("🌐 Fetching from: \(urlString)")
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(QuizResponse.self, from: data)
        
        print("✅ Got \(response.results.count) questions")
        return response.results
    }
}

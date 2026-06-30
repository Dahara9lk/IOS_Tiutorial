//
//  QuizService.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-30.
//


import Foundation

// MARK: - Custom Error Types
enum QuizServiceError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    // User-friendly error messages
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .noData:
            return "No data received from server"
        case .decodingError:
            return "Failed to decode quiz data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Quiz Service
// Handles all network requests
class QuizService {
    // API endpoint
    private let baseURL = "https://opentdb.com/api.php"
    private let session = URLSession.shared
    
    // MARK: - Fetch Questions
    // Async function that fetches 10 multiple choice questions
    func fetchQuestions(amount: Int = 10) async throws -> [Question] {
        // 1. Build the URL with parameters
        guard var components = URLComponents(string: baseURL) else {
            throw QuizServiceError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "type", value: "multiple") // Multiple choice only
        ]
        
        guard let url = components.url else {
            throw QuizServiceError.invalidURL
        }
        
        print("🔍 Fetching quiz from: \(url)")
        
        do {
            // 2. Make the network request
            let (data, response) = try await session.data(from: url)
            
            // 3. Check if response is valid
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw QuizServiceError.noData
            }
            
            // 4. Decode the JSON data
            let decoder = JSONDecoder()
            
            do {
                let quizResponse = try decoder.decode(QuizResponse.self, from: data)
                
                // 5. Check API response code
                if quizResponse.response_code != 0 {
                    // Handle API errors
                    switch quizResponse.response_code {
                    case 1:
                        throw QuizServiceError.noData
                    case 2:
                        throw QuizServiceError.invalidURL
                    default:
                        throw QuizServiceError.decodingError
                    }
                }
                
                print("✅ Fetched \(quizResponse.results.count) questions")
                return quizResponse.results
                
            } catch {
                print("❌ Decoding error: \(error)")
                throw QuizServiceError.decodingError
            }
            
        } catch let error as QuizServiceError {
            throw error
        } catch {
            print("❌ Network error: \(error)")
            throw QuizServiceError.networkError(error)
        }
    }
}

// MARK: - HTML Decoding Extension
// Helper to convert HTML entities like &quot; to actual quotes
extension String {
    var decodedHTML: String {
        guard let data = data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        return attributedString.string
    }
}

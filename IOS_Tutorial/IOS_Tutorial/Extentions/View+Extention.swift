//
//  String+Extensions.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-07-10.
//

import Foundation
import UIKit

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

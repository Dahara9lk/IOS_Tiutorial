//
//  View+Extensions.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

// This file can contain reusable view modifiers
// For example:
extension View {
    func gameButtonStyle() -> some View {
        self
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(15)
    }
}

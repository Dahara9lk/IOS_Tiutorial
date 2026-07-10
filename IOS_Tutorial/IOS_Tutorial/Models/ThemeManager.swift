//
//  ThemeManager.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-07-10.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme = .dark
    
    func toggleTheme() {
        colorScheme = colorScheme == .dark ? .light : .dark
    }
    
    var accentColor: Color {
        colorScheme == .dark ? .cyan : .blue
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.05, green: 0.05, blue: 0.15) : .white
    }
    
    var cardColor: Color {
        colorScheme == .dark ?
            Color(red: 0.1, green: 0.1, blue: 0.2) :
            Color(red: 0.95, green: 0.95, blue: 0.98)
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var secondaryTextColor: Color {
        colorScheme == .dark ? .gray : .secondary
    }
    
    var glowColor: Color {
        colorScheme == .dark ? .cyan.opacity(0.3) : .blue.opacity(0.2)
    }
    
    var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.5) : .gray.opacity(0.3)
    }
}

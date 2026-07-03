//
//  Level.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import SwiftUI

enum Level: Int {
    case l1 = 1, l2, l3, l4
    
    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }
    
    var rows: Int {
        switch self {
        case .l1: return 1
        case .l2: return 1
        case .l3: return 2
        case .l4: return 3
        }
    }
    
    var totalCards: Int {
        columns * rows
    }
    
    var litDuration: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }
    
    var litCount: Int {
        self == .l4 ? 2 : 1
    }
    
    var glowColor: Color {
        switch self {
        case .l1: return .green
        case .l2: return .blue
        case .l3: return .purple
        case .l4: return .red
        }
    }
    
    static func from(time: Int) -> Level {
        switch time {
        case 0...14: return .l1
        case 15...29: return .l2
        case 30...44: return .l3
        default: return .l4
        }
    }
}

//
//  Card.swift
//  IOS_Tutorial
//
//  Created by Student4 on 2026-06-17.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    var isLit: Bool = false
    var position: Int
    
    init(position: Int) {
        self.position = position
    }
}

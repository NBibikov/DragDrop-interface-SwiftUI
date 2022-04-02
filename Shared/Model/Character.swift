//
//  Character.swift
//  Drag&Drop interface SwiftUI (iOS)
//
//  Created by Mykola Bibikov on 02.04.2022.
//

import SwiftUI

/// Character model

struct Character: Identifiable, Hashable, Equatable {
    
    var id = UUID().uuidString
    var value: String
    var padding: CGFloat = 10
    var textSize: CGFloat = .zero
    var fontSize: CGFloat = 18
    var isShowing = false
}

var characters_: [Character] = [
    Character(value: "Id"),
    Character(value: "aliqua"),
    Character(value: "in"),
    Character(value: "laboris"),
    Character(value: "amet"),
    Character(value: "ipsum"),
    Character(value: "pariatur"),
    Character(value: "Lorem"),
    Character(value: "consequat")
    
    // Id aliqua in laboris amet ipsum cillum fugiat ad ipsum ipsum pariatur Lorem consequat.
]

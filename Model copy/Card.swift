//
//  Card.swift
//  golfCardGame
//
//  Created by Ismael Banihamed on 12/24/19.
//  Copyright © 2019 Ismael Banihamed. All rights reserved.
//

import Foundation

class Card {
    let rank: Rank
    let suit: Suit
    let image: String
    
    enum Rank: Int {
        case two = 2, three, four, five, six, seven, eight, nine, ten
        case Jack, Queen, King, Ace
        
        func rankDescription() -> String {
            switch self {
            case .Jack: return "jack"
            case .Queen: return "queen"
            case .King: return "king"
            case .Ace: return "ace"
            default: return String(self.rawValue)
            }
        }
        func cardValue() -> Int {
            switch self {
            case .Jack: return 11
            case .Queen: return 12
            case .King: return 0
            case .Ace: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
            case .ten: return 10
            default: return 5
            }
        }
    }
    enum Suit: String{
        case spades
        case hearts
        case diamonds
        case clubs
    }
    init(r: Rank, s: Suit) {
        rank = r
        suit = s
        image = "\(rank.rankDescription())_of_\(suit)"
    }
}



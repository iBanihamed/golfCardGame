//
//  Player.swift
//  golfCardGame
//
//  Created by Ismael Banihamed on 12/24/19.
//  Copyright © 2019 Ismael Banihamed. All rights reserved.
//

import Foundation

class Player {
    let location: String
    let playerNumber: Int
    var score: Int
    var done: Bool
    var hand: (card: [Card], flipped: [Bool])
    
    init(l: String, pn: Int) {
        location = l
        playerNumber = pn
        score = 0
        hand = ([Card](repeating: Card(r: Card.Rank(rawValue: 2)!, s: Card.Suit(rawValue: "spades")!), count: 4), [Bool](repeating: false, count: 4))
        done = false
    }
    
    func tradeCard(card: Card, index: Int) {
        
    }
    
    func flipCard() {
        
    }
}

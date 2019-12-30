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
    let isAI: Bool
    var score: Int
    var done: Bool
    var hand: (card: [Card], flipped: [Bool])
    
    init(l: String, pn: Int) {
        location = l
        playerNumber = pn
        isAI = (pn == 0) ? false : true
        hand = ([Card](repeating: Card(r: Card.Rank(rawValue: 2)!, s: Card.Suit(rawValue: "spades")!), count: 4), [Bool](repeating: false, count: 4))
        done = false
        score = 0
    }
    func calculateScore() -> Int {
        //check duplicates
        for i in 0...3 {
            score += (self.hand.flipped[i] == true) ? self.hand.card[i].rank.cardValue() : 0
        }
        for i in 0...3 {
            if (self.hand.flipped[i] == true) {
                for j in i+1...3 {
                    if (self.hand.card[i].rank.cardValue() == self.hand.card[j].rank.cardValue()) {
                        
                    } else {
                        
                    }
                }
            } else {
                
            }
        }
        return score
    }
    func checkDuplicates(card: Int) {
        
    }
    
}

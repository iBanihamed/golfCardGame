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
        //calculate initial score
        for i in 0...3 {
            score += (self.hand.flipped[i] == true) ? self.hand.card[i].rank.cardValue() : 0  //need to change back to true, set to false for testing purposes
        }
        //find duplicates
        var duplicates: [Int: Int] = [:]
        for i in 0...3 {
            if (self.hand.flipped[i] == true) {   //need to change back to true, set to false for testing purposes
                duplicates[self.hand.card[i].rank.cardValue()] = (duplicates[self.hand.card[i].rank.cardValue()] ?? 0) + 1
            }
        }
        print(duplicates)
        //subtract the duplicate values from the player score
        for duplicate in duplicates {
            switch duplicate.value {
            case 1:
                break
            case 2, 3:
                score -= duplicate.key * 2
                break
            case 4:
                score -= duplicate.key * 4
                break
            default: break
            }
        }
        print(score)
        return score
    }
}

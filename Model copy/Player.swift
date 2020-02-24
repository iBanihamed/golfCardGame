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
    var hand: (card: [Card], flipped: [Bool], flipping: [Bool])
    
    init(l: String, pn: Int) {
        location = l
        playerNumber = pn
        isAI = (pn == 0) ? false : true
        hand = ([Card](repeating: Card(r: Card.Rank(rawValue: 2)!, s: Card.Suit(rawValue: "spades")!), count: 4), [Bool](repeating: false, count: 4), [Bool](repeating: false, count: 4))
        done = false
        score = 0
    }
    func calculateScore() -> Int {
        score = 0
        //calculate initial score
        for i in 0...3 {
            score += (self.hand.flipped[i] == true) ? self.hand.card[i].rank.cardValue() : 0
        }
        //find duplicates
        var duplicates: [Int: Int] = [:]
        for i in 0...3 {
            if (self.hand.flipped[i] == true) {
                duplicates[self.hand.card[i].rank.cardValue()] = (duplicates[self.hand.card[i].rank.cardValue()] ?? 0) + 1
            }
        }
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
        return score
    }
    
    //AI functionality
    //finds the worst card from unflipped cards to use for trading card functionality of AI
    //if function returns 0 that means all cards are good cards and no card should be traded
    func worstCard() -> Int{
        var cardMap: [Int: Int] = [:]
        for i in 0...3 {
            if (self.hand.flipped[i] == false) {
                cardMap[self.hand.card[i].rank.cardValue()] = (cardMap[self.hand.card[i].rank.cardValue()] ?? 0) + 1
            }
        }
        print(cardMap)
        var worstCardValue = 0
        for card in cardMap {
            if (card.key > worstCardValue && (card.value == 1 || card.value == 3)) {
                worstCardValue = card.key
            }
        }
        print("Worst card: \(worstCardValue)")
        var worstCardIndex = 0
        for i in 0...3 {
            if (self.hand.card[i].rank.cardValue() == worstCardValue && self.hand.flipped[i] == false) {
                worstCardIndex = i
            }
        }
        return worstCardIndex
    }
    //finds the best card to flip, to use for trading card functionality of AI
    func bestCard() -> Int{
        var cardMap: [Int: Int] = [:]
        for i in 0...3 {
            if (self.hand.flipped[i] == false) {
                cardMap[self.hand.card[i].rank.cardValue()] = (cardMap[self.hand.card[i].rank.cardValue()] ?? 0) + 1
            }
        }
        print(cardMap)
        var bestCardValue = 13
        var bestCardIndex = 0
        for card in cardMap {
            if (card.value == 2 || card.value == 4) {
                bestCardValue = card.key
                break
            } else if (card.key < bestCardValue) {
                bestCardValue = card.key
            }
        }
        print("Best card: \(bestCardValue)")
        for i in 0...3 {
            if (self.hand.card[i].rank.cardValue() == bestCardValue && self.hand.flipped[i] == false) {
                bestCardIndex = i
            }
        }
        return bestCardIndex
    }
}

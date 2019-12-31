//
//  Deck.swift
//  golfCardGame
//
//  Created by Ismael Banihamed on 12/24/19.
//  Copyright © 2019 Ismael Banihamed. All rights reserved.
//

import Foundation

class Deck {
    var list = [Card]()
    func enqueue(_ element: Card) {
        list.append(element)
    }
    func dequeue() -> Card? {
        if !list.isEmpty {
            return list.removeFirst()
        } else {
            return nil
        }
    }
    func empty() {
        if !list.isEmpty {
            list.removeAll()
        } else {
            print("QueueEmpty")
        }
    }
    func peek() -> Card? {
        if !list.isEmpty {
            return list.last
        } else {
            return nil
        }
    }
    
    func shuffleDeck() {
        return list.shuffle()
    }
    func dealCard() -> Card? {
        if !list.isEmpty {
            return list.removeLast()
        } else {
            return nil
        }
    }
    func generateDeck(){
        let maxRank = Card.Rank.Ace.rawValue
        let aSuit:Array = [Card.Suit.clubs.rawValue, Card.Suit.diamonds.rawValue, Card.Suit.hearts.rawValue, Card.Suit.spades.rawValue]
        
        for count in 2...maxRank {
            for suit in aSuit {
                let aRank = Card.Rank.init(rawValue: count)
                let aSuit = Card.Suit.init(rawValue: suit)
                let card = Card(r: aRank!, s: aSuit!)
                list.append(card)
            }
        }
    }
}

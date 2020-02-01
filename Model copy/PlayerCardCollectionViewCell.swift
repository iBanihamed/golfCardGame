 //
//  PlayerCardCollectionViewCell.swift
//  golfCardGame
//
//  Created by Ismael Banihamed on 12/25/19.
//  Copyright © 2019 Ismael Banihamed. All rights reserved.
//

import UIKit
 
class PlayerCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardButton: UIButton!
    var isFlipped = false
    var card = Card(r: Card.Rank(rawValue: 2)!, s: Card.Suit(rawValue: "spades")!)
    
//    @IBAction func cardButtonPressed(_ sender: Any) {
//        self.imageView.image = UIImage(named: card.image)
//        self.isFlipped = true
//        delegate?.aiTurns()
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

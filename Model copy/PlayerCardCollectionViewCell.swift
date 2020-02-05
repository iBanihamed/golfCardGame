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
    var card = Card(r: Card.Rank(rawValue: 2)!, s: Card.Suit(rawValue: "spades")!)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

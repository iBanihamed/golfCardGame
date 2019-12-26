//
//  ViewController.swift
//  golfCardGame
//
//  Created by Ismael Banihamed on 12/24/19.
//  Copyright © 2019 Ismael Banihamed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var playerCardsCollectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let cellIdentifier = "playerCardCollectionViewCell"
    
    var playerCards = [Card]()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpCollectionViewItemSize()
    }
    
    private func setUpCollectionView() {
        playerCardsCollectionView.delegate = self
        playerCardsCollectionView.dataSource = self
        let nib = UINib(nibName: "playerCardCollectionViewCell", bundle: nil)
        playerCardsCollectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
 
    private func setUpCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let numberOfItemPerRow: CGFloat = 2
            let lineSpacing: CGFloat = 5
            let interItemSpacing: CGFloat  = 5
            let width = (playerCardsCollectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
            let height = width
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
        }
    }
    var dealtPile = Deck()
    var players: Array = [Player]()
    
    
    var deck = Deck()
    
    @IBOutlet weak var deckImage: UIImageView!
    @IBOutlet weak var dealtPileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deckImage.image = UIImage(named: "back")
        setUpCollectionView()
    }

    @IBAction func dealPressed(_ sender: Any) {
        deck.empty()
        deck.generateDeck()
        deck.shuffleDeck()
        
        dealtPile.empty()
        dealtPile.enqueue(deck.dealCard()!)
        dealtPileImage.image = UIImage(named: dealtPile.peek()!.image)
        
        for player in players {
            for i in 0...3 {
                player.hand.card[i] = deck.dealCard()!
            }
        }
    }
    
    func tradeCard() {
            
    }
    
    func flipCard() {
        
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
        //return players[0].hand.card.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playerCardsCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        cell.imageView.image = UIImage(named: players[0].hand.card[indexPath.item].image)
            return cell
    }
    
}


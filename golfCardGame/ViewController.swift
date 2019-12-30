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
    @IBOutlet weak var player1CardsCollectionView: UICollectionView!
    @IBOutlet weak var player2CardsCollectionView: UICollectionView!
    @IBOutlet weak var player3CardsCollectionView: UICollectionView!
    let playerCardCollectionViews: Array = [UICollectionView]()
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let cellIdentifier = "playerCardCollectionViewCell"
    
    var numberOfPlayers = 0;
    var playerCards = [Card]()
    
    @IBOutlet weak var playersPlayingLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deckImage.image = UIImage(named: "back")
        setUpCollectionView()
        playersPlayingLabel.text = "Players: \(numberOfPlayers)"
        playerCardsCollectionView.isHidden = true
        player1CardsCollectionView.isHidden = true
        player2CardsCollectionView.isHidden = true
        player3CardsCollectionView.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpCollectionViewItemSize()
    }
    
    private func setUpCollectionView() {
        playerCardsCollectionView.delegate = self
        playerCardsCollectionView.dataSource = self
        let nib = UINib(nibName: "PlayerCardCollectionViewCell", bundle: nil)
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
    
    @IBAction func playerSliderValueChanged(_ sender: UISlider) {
        numberOfPlayers = Int(sender.value)
        
        playersPlayingLabel.text = "Players: \(numberOfPlayers)"
        
    }
    
    @IBAction func dealPressed(_ sender: Any) {
        deck.empty()
        deck.generateDeck()
        deck.shuffleDeck()
        
        dealtPile.empty()
        dealtPile.enqueue(deck.dealCard()!)
        dealtPileImage.image = UIImage(named: dealtPile.peek()!.image)
        for i in 0...(numberOfPlayers - 1) {
            players.append(Player(l: "USA", pn: i))
        }
        playerCardsCollectionView.isHidden = false
        for player in players {
            for i in 0...3 {
                player.hand.card[i] = deck.dealCard()!
                playerCardsCollectionView.reloadData()
            }
        }
        //gameStart(players: players.count)
    }
    
    func drawCard() {
        dealtPile.enqueue(deck.dealCard()!)
        dealtPileImage.image = UIImage(named: dealtPile.peek()!.image)
    }
    func tradeCard(player: Int, card: Int) {
        players[player].hand.card[card] = dealtPile.dealCard()!
        players[player].hand.flipped[card] = true
    }
    func flipCard(player: Int, card: Int) {
        players[player].hand.flipped[card] = true
    }
    func playerTurn(player: Int) {
        if (players[player].hand.flipped.allSatisfy({_ in true})) {
            return
        } else {
            if (players[player].isAI == true) {
                aiTurn()
            } else {
                
            }
            //code logic for player turn
            playerScoreLabel.text = "Score: \(players[player].calculateScore())"
        }
        
    }
    //logic for the turn of a computer
    func aiTurn() {
        
    }
    func checkGame() -> Bool{
        var gameDone = false
        for player in players {
            if (player.hand.flipped.allSatisfy({_ in true})) {
                gameDone = true
            } else {
                gameDone = false
            }
        }
        return gameDone
    }
    func gameStart(players: Int) {
        while (checkGame() != true) {
            for i in 0...(players-1) {
                playerTurn(player: i)
            }
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
        //return players[0].hand.card.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playerCardsCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        cell.imageView.image = (players.isEmpty == true) ? UIImage(named: "back"): UIImage(named: players[0].hand.card[indexPath.item].image)
            return cell
    }
    
}

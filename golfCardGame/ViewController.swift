//
//  ViewController.swift
//  golfCardGame
//
//  Created by Ismael Banihamed on 12/24/19.
//  Copyright © 2019 Ismael Banihamed. All rights reserved.
//

import UIKit
import CRNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var drawCardButton: UIButton!
    @IBOutlet weak var tradeCardButton: UIButton!
    @IBOutlet weak var flipCardButton: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    
    @IBOutlet var cardCollectionViews: [UICollectionView]!
    @IBOutlet var computerScoreLabels: [UILabel]!
    
    @IBOutlet weak var deckImage: UIImageView!
    @IBOutlet weak var dealtPileImage: UIImageView!
    
    @IBOutlet weak var playersPlayingLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    let cellIdentifier = "playerCardCollectionViewCell"
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var numberOfPlayers = 1;
    var playerCards = [Card]()
    var turnFinished = true
    var dealtPile = Deck()
    var players: Array = [Player]()
    var deck = Deck()
    let MAX_PLAYERS = 4
    let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deckImage.image = UIImage(named: "back")
        setUpCollectionView()
        dealButton.isEnabled = true
        drawCardButton.isEnabled = false
        tradeCardButton.isEnabled = false
        flipCardButton.isEnabled = false
        playersPlayingLabel.text = "Players: \(numberOfPlayers)"
        for item in cardCollectionViews {
            item.isHidden = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpCollectionViewItemSize()
    }
    
    private func setUpCollectionView() {
        for item in cardCollectionViews {
            item.delegate = self
            item.dataSource = self
        }
        let nib = UINib(nibName: "PlayerCardCollectionViewCell", bundle: nil)
        for item in cardCollectionViews {
            item.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        }
    }
 
    private func setUpCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let numberOfItemPerRow: CGFloat = 2
            let lineSpacing: CGFloat = 5
            let interItemSpacing: CGFloat  = 5
            let width = (cardCollectionViews[0].frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
            let height = width
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
        }
    }

    @IBAction func playerSliderValueChanged(_ sender: UISlider) {
        numberOfPlayers = Int(sender.value)
        for i in 0...MAX_PLAYERS - 1 {
            if(i <= Int(sender.value - 1)) {
                cardCollectionViews[i].isHidden = false
            } else {
                cardCollectionViews[i].isHidden = true
            }
        }
        playersPlayingLabel.text = "Players: \(numberOfPlayers)"
    }
    
    @IBAction func dealPressed(_ sender: Any) {
        players.removeAll()
        deck.empty()
        deck.generateDeck()
        deck.shuffleDeck()
        
        dealtPile.empty()
        dealtPile.enqueue(deck.dealCard()!)
        dealtPileImage.image = UIImage(named: dealtPile.peek()!.image)
        
        for i in 0...(numberOfPlayers - 1) {
            players.append(Player(l: "USA", pn: i))
        }
        var p = 0
        for player in players {
            
            for i in 0...MAX_PLAYERS - 1 {
                player.hand.card[i] = deck.dealCard()!
            }
            cardCollectionViews[p].isHidden = false
            cardCollectionViews[p].reloadData()
            p += 1
        }
        //testing calc score function
        playerScoreLabel.text = "Score: \(players[0].calculateScore())"
        dealButton.isEnabled = false
        dealButton.isHidden = true
        flipCardButton.isEnabled = true
        flipCardButton.isHidden = false
        tradeCardButton.isEnabled = true
        tradeCardButton.isHidden = false
        drawCardButton.isEnabled = true
        drawCardButton.isHidden = false
        playerSlider.isEnabled = false
        playerSlider.isHidden = true
        playersPlayingLabel.isHidden = true
        //-------------------------
        //gameStart(playerCount: players.count)
    }
    @IBAction func drawCardPressed(_ sender: Any) {
        drawCard()
    }
    @IBAction func tradeCardPressed(_ sender: Any) {
        let cardToTrade = 0 //need to change code to accept user input for card to trade
        tradeCard(player: 0, card: cardToTrade)
        playerScoreLabel.text = "Score: \(players[0].calculateScore())"
        drawCardButton.isEnabled = false
        tradeCardButton.isEnabled = false
        flipCardButton.isEnabled = false
        aiTurns()
    }
    @IBAction func flipCardPressed(_ sender: Any) {
        let cardToFlip = 0 //need to change code to accept user input for card to trade
        flipCard(player: 0, card: cardToFlip)
        playerScoreLabel.text = "Score: \(players[0].calculateScore())"
        drawCardButton.isEnabled = false
        tradeCardButton.isEnabled = false
        flipCardButton.isEnabled = false
        aiTurns()
    }
    func drawCard() {
        dealtPile.enqueue(deck.dealCard()!)
        dealtPileImage.image = UIImage(named: dealtPile.peek()!.image)
    }
    func tradeCard(player: Int, card: Int) {
        let cardToTrade = players[player].hand.card[card]
        players[player].hand.card[card] = dealtPile.dealCard()!
        dealtPile.enqueue(cardToTrade)
        players[player].hand.flipped[card] = true
        dealtPileImage.image = UIImage(named: dealtPile.peek()!.image)
        cardCollectionViews[player].reloadData()
        
    }
    func flipCard(player: Int, card: Int) {
        players[player].hand.flipped[card] = true
        cardCollectionViews[player].reloadData()
    }
    
    func aiTurns() {
        for i in 1...players.count - 1 {
            if (dealtPile.peek()?.rank.rankDescription() == "king") {
                tradeCard(player: i, card: players[i].worstCard())
                print("card traded")
            } else {
                if(((dealtPile.peek()?.rank.cardValue())!) < players[i].worstCard()) {
                    tradeCard(player: i, card: players[i].worstCard())
                    print("card traded for better card")
                } else {
                    drawCard()
                    print("drew card")
                    if((dealtPile.peek()!.rank.cardValue()) < players[i].worstCard()) {
                        tradeCard(player: i, card: players[i].worstCard())
                        print("card traded for better card")
                    } else {
                        flipCard(player: i, card: players[i].bestCard())
                        print("card flipped")
                    }
                }
            }
        }
        drawCardButton.isEnabled = true
        tradeCardButton.isEnabled = true
        flipCardButton.isEnabled = true
        (checkGame()) ? endGame() : print("your turn")
    }
    
    func checkGame() -> Bool{
        var gameDone = false
        for player in players {
            gameDone = (player.hand.flipped.contains(false)) ? false : true
        }
        return gameDone
    }
    
    func endGame() {
        //Code end Game routine. Give user notification if they won or lost and then offer reset/retry
        var playerWon = false
        for i in 1...players.count - 1 {
            if players[0].calculateScore() < players[i].calculateScore() {
                playerWon = false
                print("You won!")
                break
            } else {
                playerWon = true
                print("you lost :(")
            }
        }
        dealButton.isEnabled = true
        dealButton.isHidden = false
        playerSlider.isEnabled = true
        playerSlider.isHidden = false
        drawCardButton.isEnabled = false
        tradeCardButton.isEnabled = false
        flipCardButton.isEnabled = false
        drawCardButton.isHidden = true
        tradeCardButton.isHidden = true
        flipCardButton.isHidden = true
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
        //return players[0].hand.card.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        //cell.imageView.image = (players.isEmpty == true) ? UIImage(named: "back"): UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
        if (players.isEmpty == true || players[collectionView.tag].hand.flipped[indexPath.item] == false) {
            cell.imageView.image = UIImage(named: "back")
        } else {
            cell.imageView.image = UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
        }
            return cell
    }
    
}


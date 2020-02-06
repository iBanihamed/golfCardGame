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
    @IBOutlet weak var playerSlider: UISlider!
    
    @IBOutlet var cardCollectionViews: [UICollectionView]!
    @IBOutlet var scoreLabels: [UILabel]!
    
    @IBOutlet weak var dealtPileButton: UIButton!
    @IBOutlet weak var deckButton: UIButton!
    
    @IBOutlet weak var playersPlayingLabel: UILabel!
    
    let cellIdentifier = "playerCardCollectionViewCell"
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var numberOfPlayers = 2
    var turnFinished = true
    var dealtPile = Deck()
    var players: Array = [Player]()
    var deck = Deck()
    var cardToTrade = 0
    var tradingCard = false
    let MAX_PLAYERS = 4
    let MAX_CARDS = 4
    let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deckButton.setImage(UIImage(named: "back"), for: UIControl.State.normal)
        setUpCollectionView()
        dealButton.isEnabled = true
        dealtPileButton.isEnabled = false
        deckButton.isEnabled = false
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
        playersPlayingLabel.text = "Players: \(numberOfPlayers)"
    }
    
    @IBAction func dealPressed(_ sender: Any) {
        players.removeAll()
        deck.empty()
        deck.generateDeck()
        deck.shuffleDeck()
        
        dealtPile.empty()
        dealtPile.enqueue(deck.dealCard()!)
        dealtPileButton.setImage(UIImage(named: dealtPile.peek()!.image), for: UIControl.State.normal)
        
        for i in 0...(numberOfPlayers - 1) {
            players.append(Player(l: "USA", pn: i))
        }
        var p = 0
        for player in players {
            for i in 0...MAX_CARDS - 1 {
                player.hand.card[i] = deck.dealCard()!
            }
            cardCollectionViews[p].isHidden = false
            cardCollectionViews[p].isUserInteractionEnabled = (p > 0) ? false : true //disabling user actions on cpu collection views/cards
            cardCollectionViews[p].reloadData()
            p += 1
        }
        for i in 0...MAX_PLAYERS - 1 {
            if i >= numberOfPlayers {
                cardCollectionViews[i].isHidden = true
                scoreLabels[i].text = ""
            } else {
                cardCollectionViews[i].isHidden = false
                scoreLabels[i].text = "Score:"
            }
        }
        dealButton.isEnabled = false
        dealButton.isHidden = true
        dealtPileButton.isEnabled = true
        deckButton.isEnabled = true
        playerSlider.isEnabled = false
        playerSlider.isHidden = true
        playersPlayingLabel.isHidden = true
        //-------------------------
        //gameStart(playerCount: players.count)
    }
    
    @IBAction func deckCardButtonPressed(_ sender: Any) {
        drawCard()
    }
    
    //action to trade Card
    @IBAction func dealtPileButtonPressed(_ sender: Any) {
        tradingCard = true
//        UIView.animate(withDuration: 2.0, animations: {
//                self.dealtPileButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//            })
        highlightCards(highLight: true)
    }
    func drawCard() {
        dealtPile.enqueue(deck.dealCard()!)
        dealtPileButton.setImage(UIImage(named: dealtPile.peek()!.image), for: UIControl.State.normal)
    }
    func tradeCard(player: Int, card: Int) {
        let cardToTrade = players[player].hand.card[card]
        players[player].hand.card[card] = dealtPile.dealCard()!
        dealtPile.enqueue(cardToTrade)
        players[player].hand.flipped[card] = true
        scoreLabels[player].text = "Score: \(players[player].calculateScore())"
        dealtPileButton.setImage(UIImage(named: dealtPile.peek()!.image), for: UIControl.State.normal)
        cardCollectionViews[player].reloadData()
    }
    func flipCard(player: Int, card: Int) {
        players[player].hand.flipped[card] = true
        scoreLabels[player].text = "Score: \(players[player].calculateScore())"
        cardCollectionViews[player].reloadData()
    }
    func highlightCards(highLight: Bool) {
        var playerCells = [PlayerCardCollectionViewCell]()
        for i in 0...MAX_CARDS - 1 {
            playerCells.append(cardCollectionViews[0].dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: IndexPath(item: i, section: 0)) as! PlayerCardCollectionViewCell)
        }
        if highLight {
            for card in 0...MAX_CARDS - 1 {
                if (players[0].hand.flipped[card] == false) {
                    cardCollectionViews[0].cellForItem(at: IndexPath(item: card, section: 0))?.backgroundColor = UIColor.blue
                }
            }
        } else {
            for card in 0...MAX_CARDS - 1 {
                if (players[0].hand.flipped[card] == false) {
                    playerCells[card].backgroundColor = UIColor.clear
                    cardCollectionViews[0].cellForItem(at: IndexPath(item: card, section: 0))?.backgroundColor = UIColor.clear
                }
            }
        }
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
        deckButton.isEnabled = true
        dealtPileButton.isEnabled = true
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
                playerWon = true
            } else {
                playerWon = false
                CRNotifications.showNotification(type: CRNotifications.info, title: "You lost 😤", message: "Better luck next time", dismissDelay: 3)
                break
            }
        }
        if playerWon {
            CRNotifications.showNotification(type: CRNotifications.info, title: "You won 😁", message: "Aye", dismissDelay: 3)
        }
        dealButton.isEnabled = true
        dealButton.isHidden = false
        playerSlider.isEnabled = true
        playerSlider.isHidden = false
        deckButton.isEnabled = false
        dealtPileButton.isEnabled = false
        playersPlayingLabel.isHidden = false
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MAX_CARDS
        //return players[0].hand.card.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        //cell.imageView.image = (players.isEmpty == true) ? UIImage(named: "back"): UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
        //set image of card
        if (players.isEmpty == true) {
            cell.imageView.image = UIImage(named: "back")
        } else if (players[collectionView.tag].hand.flipped[indexPath.item] == false) {
            cell.card = players[collectionView.tag].hand.card[indexPath.item]
            cell.imageView.image = UIImage(named: "back")
        } else {
            cell.card = players[collectionView.tag].hand.card[indexPath.item]
            cell.imageView.image = UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        if (tradingCard == true) {
//            UIView.animate(withDuration: 2.0, animations: {
//                self.dealtPileButton.center = CGPoint(x: cell.frame.origin.x, y: cell.frame.origin.y)
//            })
            tradeCard(player: collectionView.tag, card: indexPath.item)
            cell.card = players[collectionView.tag].hand.card[indexPath.item]
            cell.imageView.image = UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
            highlightCards(highLight: false)
            tradingCard = false
        } else {
            cell.card = players[collectionView.tag].hand.card[indexPath.item]
            cell.imageView.image = UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
            flipCard(player: collectionView.tag, card: indexPath.item)
        }
        deckButton.isEnabled = false
        dealtPileButton.isEnabled = false
        aiTurns()
    }
    
}


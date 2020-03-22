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
    @IBOutlet weak var deckBackgroundImage: UIImageView!
    
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
    var drewCard = false;
    var cardsTraded = 0
    var cardsDrawn = 0
    var cardsFlipped = 0
    let MAX_PLAYERS = 4
    let MAX_CARDS = 4
    let DRAW_CARD_DURATION = 1
    let TRADE_CARD_DURATION = 2
    let FLIP_CARD_DURATION = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        deckButton.setImage(UIImage(named: "back"), for: UIControl.State.normal)
        setUpCollectionView()
        dealButton.isEnabled = true
        dealtPileButton.isEnabled = false
        deckButton.isEnabled = false
        deckBackgroundImage.image = UIImage(named: "back")
        deckBackgroundImage.frame = deckButton.frame
        playersPlayingLabel.text = "Players: \(numberOfPlayers)"
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
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
        clearPrevGame()
        for player in 0...numberOfPlayers - 1 {
            players.append(Player(l: "USA", pn: player))
            for card in 0...MAX_CARDS - 1 {
                players[player].hand.card[card] = deck.dealCard()!
            }
            cardCollectionViews[player].isScrollEnabled = false
            cardCollectionViews[player].isHidden = false
            cardCollectionViews[player].layer.borderWidth = 2.0
            cardCollectionViews[player].layer.borderColor = UIColor.white.cgColor
            cardCollectionViews[player].isUserInteractionEnabled = (player > 0) ? false : true //disabling user actions on cpu collection views/cards
            scoreLabels[player].isHidden = false
            scoreLabels[player].text = "Score:"
        }
        dealButton.isEnabled = false
        dealButton.isHidden = true
        dealtPileButton.isEnabled = true
        deckButton.isEnabled = true
        playerSlider.isEnabled = false
        playerSlider.isHidden = true
        playersPlayingLabel.isHidden = true
        dealCards()
    }
    
    func clearPrevGame() {
        players.removeAll()
        deck.empty()
        deck.generateDeck()
        deck.shuffleDeck()
        
        dealtPile.empty()
        dealtPile.enqueue(deck.dealCard()!)
        //dealtPileButton.setImage(UIImage(named: dealtPile.peek()!.image), for: UIControl.State.normal)
        //dealtPileButton.backgroundColor = UIColor.white
        drewCard = false
        for player in 0...MAX_PLAYERS - 1 {
            cardCollectionViews[player].isHidden = true
            scoreLabels[player].isHidden = true
        }
    }
    func dealCards() {
        let deckButtonRect = deckButton.frame
        UIView.animate(withDuration: 0.2, animations: {
            self.deckButton.frame = CGRect(x: self.dealtPileButton.frame.origin.x, y: self.dealtPileButton.frame.origin.y, width: self.dealtPileButton.frame.width, height: self.dealtPileButton.frame.height)
        }, completion: { (finished: Bool) in
            self.dealtPileButton.setImage(UIImage(named: self.dealtPile.peek()!.image), for: UIControl.State.normal)
            self.dealtPileButton.backgroundColor = UIColor.white
            self.deckButton.frame = CGRect(x: deckButtonRect.origin.x, y: deckButtonRect.origin.y, width: deckButtonRect.width, height: deckButtonRect.height)
            self.dealingCardsAnimation(player: 0, card: 0)
        })
    }
    
    func dealingCardsAnimation(player: Int, card: Int) {
        if ((player <= numberOfPlayers - 1) && (card <= MAX_CARDS - 1)) {
            var p = player
            var c = card
            let indexPath = IndexPath(item: card, section: 0)
            let cell = cardCollectionViews[player].cellForItem(at: indexPath)
            let cellV = self.cardCollectionViews[player].dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
            let cellRect = cell!.frame
            let deckRect = deckButton.frame
            let originInRootView = cardCollectionViews[player].convert(cellRect.origin, to: self.view)
            //resize deck card to cell size and move to position of cell and then return to original position
            UIView.animate(withDuration: 0.2, animations: {
                self.deckButton.frame = CGRect(x: originInRootView.x, y: originInRootView.y, width: cellRect.width, height: cellRect.height)
            }, completion: { (finished: Bool) in
                cell?.layer.backgroundColor = UIColor.white.cgColor
                cellV.card = self.players[player].hand.card[card]
                cellV.imageView.image = UIImage(named: self.players[player].hand.card[card].image)
                self.cardCollectionViews[player].reloadItems(at: [indexPath])
                self.deckButton.frame = CGRect(x: deckRect.origin.x, y: deckRect.origin.y, width: deckRect.width, height: deckRect.height)
                if card == 3 {
                    p += 1
                    c = 0
                } else {
                    c += 1
                }
                self.dealingCardsAnimation(player: p, card: c)
            })
        } else {
            print("Cards Dealt")
        }
    }
    @IBAction func deckCardButtonPressed(_ sender: Any) {
        if (drewCard == true) {
            CRNotifications.showNotification(type: CRNotifications.info, title: "✋", message: "Hold it there bud", dismissDelay: 1)
        } else {
            drewCard = true
            drawCard()
        }
    }
    //action to trade Card
    @IBAction func dealtPileButtonPressed(_ sender: Any) {
        view.bringSubviewToFront(dealtPileButton)
        tradingCard = true
        UIView.animate(withDuration: 1.0, animations: {
            var i = 0
            for cell in self.cardCollectionViews[0].visibleCells {
                if self.players[0].hand.flipped[i] == false {
                    cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    cell.layer.borderColor = UIColor.yellow.cgColor
                    cell.layer.borderWidth = 2.0
                }
                i += 1
            }
        })
    }
    
    func drawCard() {
        let orgRect = deckButton.frame
        view.bringSubviewToFront(deckButton)
        UIView.animate(withDuration: 1.0, animations: {
            UIView.transition(with: self.deckButton.imageView!, duration: 1.0, options: .transitionFlipFromLeft, animations: {
                self.deckButton.setImage(UIImage(named: self.deck.peek()!.image), for: UIControl.State.normal)
            }, completion: nil)
            self.deckButton.frame = CGRect(x: self.dealtPileButton.frame.origin.x, y: self.dealtPileButton.frame.origin.y, width: self.dealtPileButton.frame.width, height: self.dealtPileButton.frame.height)
        }, completion: { (finished: Bool) in
            self.dealtPile.enqueue(self.deck.dealCard()!)
            self.dealtPileButton.setImage(UIImage(named: self.dealtPile.peek()!.image), for: UIControl.State.normal)
            self.deckButton.frame = CGRect(x: orgRect.origin.x, y: orgRect.origin.y, width: orgRect.width, height: orgRect.height)
            self.deckButton.setImage(UIImage(named: "back"), for: UIControl.State.normal)
        })
    }
    
    func tradeCard(player: Int, card: Int) {
        let indexPath = IndexPath(item: card, section: 0)
        let cell = cardCollectionViews[player].cellForItem(at: indexPath)
        let cellV = cardCollectionViews[player].dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        let cellRect = cell!.frame
        let dealtPileRect = dealtPileButton.frame
        let originInRootView = cardCollectionViews[player].convert(cellRect.origin, to: self.view)
        //resize dealt card to cell size and move to position of cell exchange cards and move dealt card back to original position
        UIView.animate(withDuration: 1.0, animations: {
            self.dealtPileButton.frame = CGRect(x: originInRootView.x, y: originInRootView.y, width: cellRect.width, height: cellRect.height)
        }, completion: { (finished: Bool) in
            self.trade(player: player, card: indexPath.item)
            cellV.card = self.players[player].hand.card[indexPath.item]
            UIView.animate(withDuration: 1.0, animations: {
                self.dealtPileButton.frame = CGRect(x: dealtPileRect.origin.x, y: dealtPileRect.origin.y, width: dealtPileRect.width, height: dealtPileRect.height)
            })
        })
    }
    
    func trade(player: Int, card: Int) {
        let indexPath = IndexPath(item: card, section: 0)
        let cardToTrade = self.players[player].hand.card[card]
        players[player].hand.card[card] = dealtPile.dealCard()!
        dealtPile.enqueue(cardToTrade)
        players[player].hand.flipped[card] = true
        scoreLabels[player].text = "Score: \(players[player].calculateScore())"
        dealtPileButton.setImage(UIImage(named: dealtPile.peek()!.image), for: UIControl.State.normal)
        //cardCollectionViews[player].reloadItems(at: [indexPath])
        cardCollectionViews[player].reloadData()
    }
    
    func flipCard(player: Int, card: Int) {
        let indexPath = IndexPath(item: card, section: 0)
        let cell = cardCollectionViews[player].dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        UIView.transition(with: cell.contentView, duration: 2.0, options: .transitionFlipFromLeft, animations: {
            cell.imageView.image = UIImage(named: self.players[player].hand.card[indexPath.item].image)
        }, completion: nil)
        players[player].hand.flipped[card] = true
        scoreLabels[player].text = "Score: \(players[player].calculateScore())"
        cardCollectionViews[player].reloadItems(at: [indexPath])
    }
    
    func aiTurns() {
        var turn_duration = 0
        for player in 1...players.count - 1 {
            //turn_duration += cardsTraded * TRADE_CARD_DURATION + cardsFlipped * FLIP_CARD_DURATION + cardsDrawn * DRAW_CARD_DURATION
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(turn_duration), execute: {
                self.aiTurnLogic(player: player)
            })
            turn_duration += 3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(turn_duration), execute: {
            (self.checkGame()) ? self.endGame() : print("your turn")
        })
    }
    
    func aiTurnLogic(player: Int){
        var turn_duration = 0
        print("Player \(player)'s turn")
        if (dealtPile.peek()?.rank.rankDescription() == "king") {
            tradeCard(player: player, card: players[player].worstCard())
            print("traded \(players[player].worstCard()) for a King")
            turn_duration += TRADE_CARD_DURATION
        } else {
            if(((dealtPile.peek()?.rank.cardValue())!) < players[player].worstCard()) {
                tradeCard(player: player, card: players[player].worstCard())
                print("traded \(dealtPile.peek()!.rank.cardValue()) for \(players[player].worstCard())")
                turn_duration += TRADE_CARD_DURATION
            } else {
                drawCard()
                turn_duration += DRAW_CARD_DURATION
                print("drew \(dealtPile.peek()!.rank.rankDescription())")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(turn_duration), execute: {
                    if((self.dealtPile.peek()!.rank.cardValue()) < self.players[player].worstCard()) {
                        self.tradeCard(player: player, card: self.players[player].worstCard())
                        print("traded \(self.dealtPile.peek()!.rank.cardValue()) for \(self.players[player].worstCard())")
                        turn_duration += self.TRADE_CARD_DURATION
                    } else {
                        self.flipCard(player: player, card: self.players[player].bestCard())
                        print("flipped \(self.players[player].bestCard())")
                        turn_duration += self.FLIP_CARD_DURATION
                    }
                })
            }
        }
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
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imgWidth = collectionView.frame.width
        return CGSize(width: imgWidth, height: imgWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        cell.imageView.contentMode = UIView.ContentMode.scaleToFill
        if (players.isEmpty == true) {
            return cell
//            cell.layer.borderColor = UIColor.blue.cgColor
//            cell.layer.borderWidth = 2.0
        } else if (players[collectionView.tag].hand.flipped[indexPath.item] == false) {
            if (collectionView.tag == 0 && (indexPath.item == 2 || indexPath.item == 3)) {
                cell.card = players[collectionView.tag].hand.card[indexPath.item]
                cell.imageView.image = UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
                cell.backgroundColor = UIColor.white
            } else {
                cell.card = players[collectionView.tag].hand.card[indexPath.item]
                cell.imageView.image = UIImage(named: "back")
            }
            cell.layer.borderColor = UIColor.blue.cgColor
            cell.layer.borderWidth = 2.0
        } else {
            cell.card = players[collectionView.tag].hand.card[indexPath.item]
            cell.imageView.image = UIImage(named: players[collectionView.tag].hand.card[indexPath.item].image)
            cell.layer.borderColor = UIColor.red.cgColor
            cell.layer.borderWidth = 2.0
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PlayerCardCollectionViewCell
        cell.beingFlipped = true
        var turn_duration = 0
        if (tradingCard == true) {
            self.tradeCard(player: collectionView.tag, card: indexPath.item)
            turn_duration += TRADE_CARD_DURATION
            tradingCard = false
        } else {
            self.flipCard(player: collectionView.tag, card: indexPath.item)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(turn_duration), execute: {
            self.aiTurns()
            self.drewCard = false
        })
    }
}

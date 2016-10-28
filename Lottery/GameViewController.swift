//
//  GameViewController.swift
//  Lottery
//
//  Created by Peter Brooks on 9/5/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

// TODO - swiftspinner, get rid of HandySwift


import UIKit
import CoreLocation

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var sortedColumnHeader: UILabel!

    struct sortedColumnHeaderText {
        static let oddsToWin = "Odds to Win 1:"
        static let topPrize = "Top Prize"
        static let payout = "Total Payout"
    }
    
    struct segmentOptionIs {
        static let oddsToWin = 0
        static let payout = 1
        static let topPrize = 2
        
    }
    
    class gameData {
        var wager               = 0
        var topPrize            = 0
        var oddsToWin           = 0.0
        var oddsToWinTopPrize   = 0
        var totalWinners        = 0
        var totalWinnings       = 0
        var topPrizeDetails     = ""
        var gameType            = ""
        var updateDate          = ""
    }

    var gamesSortedByOddsToWin    : [OddsToWinData] = []               // array of game classes sorted bg OddsToWin
    var gamesSortedByTopPrize     : [TopPrizeData] = []               // array of game classes sorted by maximum prize
    var gamesSortedByPayout       : [PayoutData] = []               // array of game classes sorted by maximum payout
    
    
    class OddsToWinData {
        var name                = ""
        var oddsToWin           = 0.0
        init (name: String, oddsToWin: Double) {
            self.name = name
            self.oddsToWin = oddsToWin
        }
    }
    
    class TopPrizeData {
        var name               = ""
        var topPrize           = 0
        init (name: String, topPrize: Int) {
            self.name = name
            self.topPrize = topPrize
        }
    }
    
    class PayoutData {
        var name             = ""
        var payout           = 0
        init (name: String, payout: Int) {
            self.name = name
            self.payout = payout
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate      = self
        tableView.dataSource    = self
        
        NotificationCenter.default.addObserver(forName: Notification.Name(K.allGamesNotification), object: nil, queue: nil, using: allGamesNotification)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            if locationIsAlreadySaved() {
                try Public.getGamesFromFirebase()
            } else {
                try Public.getLocationAndGetGamesFromFirebase()
            }
        } catch {
            print("error = \(error.localizedDescription)")
        }
        
        do  {
            try Public.getPickerLocationsFromFirebase()
            
        } catch {
            print("error = \(error.localizedDescription)")
        }
    }

    
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        if let header = tableHeaderView {
            
            header.frame.size.height = 44.0
            
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var returnValue = 0
        
        switch(segmentedControl.selectedSegmentIndex)
        {
        case segmentOptionIs.oddsToWin:
            returnValue = gamesSortedByOddsToWin.count
            break
        case segmentOptionIs.payout:
            returnValue = gamesSortedByPayout.count
            break
            
        case segmentOptionIs.topPrize:
            returnValue = gamesSortedByTopPrize.count
            break
            
        default:
            break
            
        }
        
        return returnValue
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "GameCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GameTableViewCell
        
        switch(segmentedControl.selectedSegmentIndex)
        {
        case segmentOptionIs.oddsToWin:
            
            let gamesRow = gamesSortedByOddsToWin[(indexPath as NSIndexPath).row]
            cell.gameName.text = gamesRow.name
            cell.gameValue.text = String(gamesRow.oddsToWin)
            
            break
        case segmentOptionIs.topPrize:
            let gamesRow = gamesSortedByTopPrize[(indexPath as NSIndexPath).row]
            cell.gameName.text = gamesRow.name
            if (gamesRow.topPrize == 0) {
                cell.gameValue.text = "varies"
            } else {
                cell.gameValue.text = priceFromInt(gamesRow.topPrize)
            }
            break
            
        case segmentOptionIs.payout:
            
            let gamesRow = gamesSortedByPayout[(indexPath as NSIndexPath).row]
            cell.gameName.text = gamesRow.name
            cell.gameValue.text = String(gamesRow.payout)
            
            break
            
        default:
            break
            
        }
        
        return cell
    }
    
    @IBAction func segmentedControlActionChanged(_ sender: UISegmentedControl) {
        
        setTableHeader(segmentedControl)
        tableView.reloadData()
        SharedServices.sharedInstance.saveToUserDefaultsTheValue(value: segmentedControl.selectedSegmentIndex, forKey: K.segmentNumKey)
    
    }
    
    func formatName(_ oldName: String) -> String? {
        
        var newName = oldName
        if !(oldName.isEmpty) {
            let range = newName.startIndex..<newName.characters.index(newName.startIndex, offsetBy: 4)
            newName.removeSubrange(range)
            newName = newName.replacingOccurrences(of: "@", with: "$")
        
        }
        
        return(newName)
        
    }
    
    func setTableHeader(_ segmentOption: UISegmentedControl) {
        
        switch(segmentOption.selectedSegmentIndex)
        {
        case segmentOptionIs.oddsToWin:
            
            sortedColumnHeader.text = sortedColumnHeaderText.oddsToWin
            break
            
        case segmentOptionIs.payout:
            
            sortedColumnHeader.text = sortedColumnHeaderText.payout
            break
            
        case segmentOptionIs.topPrize:
            
            sortedColumnHeader.text = sortedColumnHeaderText.topPrize
            break
            
        default:
            break
            
        }
    
    }
    
    
    // MARK: Add games
    
    func allGamesNotification (notification: Notification) {
        
        gamesSortedByOddsToWin = []
        gamesSortedByTopPrize = []
        gamesSortedByPayout = []
        
        // info is a dictionary of games
        if notification.userInfo?[K.gamesDictionary] != nil {
            let gamesDict = notification.userInfo?[K.gamesDictionary] as! NSDictionary
            for(name, data) in gamesDict {
                
                let thisGame = createGameObject(fromData: data as! NSDictionary)
                
                let newOddsToWinGame = OddsToWinData(name: name as! String, oddsToWin: thisGame.oddsToWin)
                gamesSortedByOddsToWin.append(newOddsToWinGame)
                let newTopPrizeGame = TopPrizeData(name: name as! String, topPrize: thisGame.topPrize)
                gamesSortedByTopPrize.append(newTopPrizeGame)
                let newPayoutGame = PayoutData(name: name as! String, payout: thisGame.totalWinners)
                gamesSortedByPayout.append(newPayoutGame)
            }
            
            gamesSortedByOddsToWin.sort { $0.oddsToWin > $1.oddsToWin }
            gamesSortedByTopPrize.sort { $0.topPrize > $1.topPrize }
            gamesSortedByPayout.sort { $0.payout > $1.payout }
            tableView.reloadData()

        }
    }
    
    
    // MARK: Create game
    
    func createGameObject(fromData: NSDictionary) -> gameData {
        
        // Note: Need to downcast all JSON fields. "Segemention fault: 11" error means mismatch between var definition and JSON definition
        // Numbers with no decimal point in the dict are NSNumbers, with "" are Strings, and with decimal point are Doubles
        
        let game = fromData
        let thisGame = gameData()
        thisGame.wager = Int(game["Wager"] as! NSNumber)
        thisGame.topPrize = Int(game["Top Prize"] as! NSNumber)
        thisGame.oddsToWin = game["Odds To Win"] as! Double
        thisGame.totalWinners = Int(game["Total Winners"] as! NSNumber)
        thisGame.totalWinnings = Int(game["Total Winnings"] as! NSNumber)
        thisGame.oddsToWinTopPrize = Int(game["Odds To Win Top Prize"] as! NSNumber)
        thisGame.topPrizeDetails = game["Top Prize Details"] as! String
        thisGame.gameType = game["Type"] as! String
        thisGame.updateDate = game["Updated"] as! String
        return thisGame
    }
    
       
    // MARK: Convenience funcs
    
    func priceFromInt(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.positiveFormat = "$#,##0"
        formatter.zeroSymbol = ""
        // formatter.locale = NSLocale.currentLocale()  // This is the default
        return(formatter.string(from: NSNumber(value: num)))!       // "$123.44"
    }
    
    func locationIsAlreadySaved() -> Bool {
        return (Public.getValueFromUserDefaultsForKey(K.countryKey) != nil)
    }
    
}

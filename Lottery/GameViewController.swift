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
//import Firebase
//import SwiftLocation

/*fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}*/


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

    //var gameDetail = [String : gameData]()
    
    
    
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
        //NotificationCenter.default.addObserver(forName: Notification.Name(K.addGameNotification), object: nil, queue: nil, using: addGameNotification)
        //NotificationCenter.default.addObserver(forName: Notification.Name(K.changeGameNotification), object: nil, queue: nil, using: addGameNotification)
        //NotificationCenter.default.addObserver(forName: Notification.Name(K.removeGameNotification), object: nil, queue: nil, using: addGameNotification)
        
        
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

            
            
            // add games to each file
    
        }
    }
    
    
    
    /*func addGameNotification (notification: Notification) {
        
        let snapshot = notification.userInfo?["snapshot"] as! FIRDataSnapshot
        let gameName = snapshot.key
        let thisGame = createGameObjectUsingSnapshot(snapshot)
        
        // Add game to details and update games arrays
        gameDetail[gameName] = thisGame
        addGameSortedByOddsToWin(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)
        addGameSortedByTopPrize(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)
        addGameSortedByPayout(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)
        
    }

    func changeGameNotification (notification: Notification) {
    
        let snapshot = notification.userInfo?["snapshot"] as! FIRDataSnapshot
        let gameName = snapshot.key
        let thisGame = createGameObjectUsingSnapshot(snapshot)
        
        // Add game to details and update games arrays
        gameDetail[gameName] = thisGame
        changeGameSortedByOddsToWin(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)
        changeGameSortedByTopPrize(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)
        changeGameSortedByPayout(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)

    
    }

    func removeGameNotification (notification: Notification) {
    
        let snapshot = notification.userInfo?["snapshot"] as! FIRDataSnapshot
        let gameName = snapshot.key
        let thisGame = createGameObjectUsingSnapshot(snapshot)
        
        // Add game to details and update games arrays
        gameDetail[gameName] = thisGame
        removeGameSortedByOddsToWin(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)
        removeGameSortedByTopPrize(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)
        removeGameSortedByPayout(thisGame, gameName: gameName, tableView: self.tableView, segmentIndex: self.segmentedControl.selectedSegmentIndex)

    
    }*/

    
    /*func addGameSortedByOddsToWin (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let thisOddsToWin = Public.sortedByOddsToWin(name: gameName, oddsToWin: thisGame.oddsToWin)
        
        var rowNumber = 0
        
        // if the new Odds to win > any in the existing array
        
        if Public.Var.gamesByOddsToWin.isEmpty || (thisGame.oddsToWin >= (Public.Var.gamesByOddsToWin.last?.oddsToWin)!) {
            
            Public.Var.gamesByOddsToWin.append(thisOddsToWin)
            rowNumber = Public.Var.gamesByOddsToWin.count-1
            
        } else {
            
            let indexOfFirstGreaterValue = Public.Var.gamesByOddsToWin.index(where: {$0.oddsToWin > thisGame.oddsToWin })
            Public.Var.gamesByOddsToWin.insert(thisOddsToWin, at: indexOfFirstGreaterValue!)
            rowNumber = indexOfFirstGreaterValue!
            
        }
        
        if segmentIndex == segmentOptionIs.oddsToWin {
            self.tableView.insertRows(at: [IndexPath(row: rowNumber, section: 0)], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func addGameSortedByTopPrize (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let thisTopPrize = Public.sortedByTopPrize(name: gameName, topPrize: thisGame.topPrize)
        var rowNumber = 0
        
        // if the new prize > any in the existing array
        if  Public.Var.gamesByTopPrize.isEmpty || (thisGame.topPrize <= (Public.Var.gamesByTopPrize.last?.topPrize)!) {
            Public.Var.gamesByTopPrize.append(thisTopPrize)
            rowNumber = Public.Var.gamesByTopPrize.count-1
        } else {
            
            let indexOfFirstLowerValue = Public.Var.gamesByTopPrize.index(where: {$0.topPrize < thisGame.topPrize })
            Public.Var.gamesByTopPrize.insert(thisTopPrize, at: indexOfFirstLowerValue!)
            rowNumber = indexOfFirstLowerValue!
            
        }
        if segmentIndex == segmentOptionIs.topPrize {
            self.tableView.insertRows(at: [IndexPath(row: rowNumber, section: 0)], with: UITableViewRowAnimation.automatic)
        }
    }

    func addGameSortedByPayout (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let thisPayout = Public.sortedByPayout(name: gameName, payout: thisGame.totalWinnings)
        
        var rowNumber = 0
        
        // if the new prize > any in the existing array
        
        if Public.Var.gamesByPayout.isEmpty || (thisGame.totalWinnings <= (Public.Var.gamesByPayout.last?.payout)!) {
            Public.Var.gamesByPayout.append(thisPayout)
            rowNumber = Public.Var.gamesByPayout.count-1
        } else {
            
            let indexOfFirstLowerValue = Public.Var.gamesByTopPrize.index(where: {$0.topPrize < thisGame.topPrize })
            Public.Var.gamesByPayout.insert(thisPayout, at: indexOfFirstLowerValue!)
            rowNumber = indexOfFirstLowerValue!
            
        }
        
        if segmentIndex == segmentOptionIs.payout {
            self.tableView.insertRows(at: [IndexPath(row: rowNumber, section: 0)], with: UITableViewRowAnimation.automatic)
        }
    }

    // MARK: Change games
    
    func changeGameSortedByOddsToWin (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let currentIndex = Public.Var.gamesByOddsToWin.index(where: {$0.name == gameName})                  // find index of current row
        let newIndex = Public.Var.gamesByOddsToWin.index(where: {$0.oddsToWin >= thisGame.oddsToWin})   // find index of new row
        
        let newRow =  Public.sortedByOddsToWin(name:gameName, oddsToWin: thisGame.oddsToWin)
        
        Public.Var.gamesByOddsToWin.remove(at: currentIndex!)
        if segmentIndex == segmentOptionIs.oddsToWin {
            self.tableView.deleteRows(at: [IndexPath(row: currentIndex!, section: 0)], with: UITableViewRowAnimation.automatic)
        }
        
        Public.Var.gamesByOddsToWin.insert(newRow, at: newIndex!)
        if segmentIndex == segmentOptionIs.oddsToWin {
            self.tableView.insertRows(at: [IndexPath(row: newIndex!, section: 0)], with: UITableViewRowAnimation.automatic)
        }
        
    }
    
    func changeGameSortedByTopPrize (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let currentIndex = Public.Var.gamesByTopPrize.index(where: {$0.name == gameName})                  // find index of current row
        let newIndex = Public.Var.gamesByTopPrize.index(where: {$0.topPrize <= thisGame.topPrize})   // find index of new row
        
        let newRow =  Public.sortedByTopPrize(name:gameName, topPrize:  thisGame.topPrize)
        
        Public.Var.gamesByTopPrize.remove(at: currentIndex!)
        if segmentIndex == segmentOptionIs.topPrize {
            self.tableView.deleteRows(at: [IndexPath(row: currentIndex!, section: 0)], with: UITableViewRowAnimation.automatic)
        }
        
        Public.Var.gamesByTopPrize.insert(newRow, at: newIndex!)
        if segmentIndex == segmentOptionIs.topPrize {
            self.tableView.insertRows(at: [IndexPath(row: newIndex!, section: 0)], with: UITableViewRowAnimation.automatic)
        }

    }
    
    func changeGameSortedByPayout (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let currentIndex = Public.Var.gamesByPayout.index(where: {$0.name == gameName})                  // find index of current row
        let newIndex = Public.Var.gamesByPayout.index(where: {$0.payout <= thisGame.totalWinnings})   // find index of new row
        
        let newRow =  Public.sortedByPayout(name:gameName, payout:  thisGame.totalWinnings)
        
        Public.Var.gamesByPayout.remove(at: currentIndex!)
        if segmentIndex == segmentOptionIs.payout {
            self.tableView.deleteRows(at: [IndexPath(row: currentIndex!, section: 0)], with: UITableViewRowAnimation.automatic)
        }
        
        Public.Var.gamesByPayout.insert(newRow, at: newIndex!)
        if segmentIndex == segmentOptionIs.payout {
            self.tableView.insertRows(at: [IndexPath(row: newIndex!, section: 0)], with: UITableViewRowAnimation.automatic)
        }

       
    }

    // MARK: Move games
    
    func removeGameSortedByOddsToWin (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let rowNumber = Public.Var.gamesByOddsToWin.index(where: {$0.name == gameName})
        Public.Var.gamesByOddsToWin.remove(at: rowNumber!)
        
        if segmentIndex == segmentOptionIs.oddsToWin {
            self.tableView.deleteRows(at: [IndexPath(row: rowNumber!, section: 0)], with: UITableViewRowAnimation.automatic)
        }
        
    }

    func removeGameSortedByTopPrize (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let rowNumber = Public.Var.gamesByTopPrize.index(where: {$0.name == gameName})
        Public.Var.gamesByTopPrize.remove(at: rowNumber!)
        
        if segmentIndex == segmentOptionIs.topPrize {
            self.tableView.deleteRows(at: [IndexPath(row: rowNumber!, section: 0)], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func removeGameSortedByPayout (_ thisGame: gameData, gameName: String, tableView: UITableView, segmentIndex: Int) {
        
        let rowNumber = Public.Var.gamesByPayout.index(where: {$0.name == gameName})
        Public.Var.gamesByPayout.remove(at: rowNumber!)
        
        if segmentIndex == segmentOptionIs.payout {
            self.tableView.deleteRows(at: [IndexPath(row: rowNumber!, section: 0)], with: UITableViewRowAnimation.automatic)
        }
        
    }*/
    
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
    
    /*func createGameObjectUsingSnapshot(_ snapshot: FIRDataSnapshot) -> gameData {
        
        // Note: Need to downcast all JSON fields. "Segemention fault: 11" error means mismatch between var definition and JSON definition
        // Numbers with no decimal point in the dict are NSNumbers, with "" are Strings, and with decimal point are Doubles
        
        let game = snapshot.value! as! NSDictionary
        let thisGame = Public.gameData()
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
    }*/
    
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

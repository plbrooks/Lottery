//
//  SettingsViewController.swift
//  Lottery
//
//  Created by Peter Brooks on 9/25/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

   
    // MARK: IBOutlets

    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: var definitions

    var ref: FIRDatabaseReference!
    var refHandleGetLocations: FIRDatabaseHandle!
    
    
    var showPickerRow = false
    
    
    // MARK: Initialization functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name(K.saveNotification), object: nil, queue: nil, using: catchSaveNotification)
        NotificationCenter.default.addObserver(forName: Notification.Name(K.cancelNotification), object: nil, queue: nil, using: catchCancelNotification)
        NotificationCenter.default.addObserver(forName: Notification.Name(K.pickerLocationsUpdatedNotification), object: nil, queue: nil, using: catchPickerLocationsUpdatedNotification)
        
        showPickerRow = false

    }
    
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)

    }

    // add guards
    
    func catchSaveNotification (notification: Notification) {
        
        // check division = nil e.g. there used to be a div now there is not
        
        let selectedCountry = notification.userInfo?["selectedCountry"] as! Int
        let countryName = Public.Var.allCountries[selectedCountry]
        Public.saveToUserDefaultsTheValue(countryName,K.countryKey)
        
        //let selectedDivision = notification.userInfo?["selectedDivision"] as! Int
        
        var divisionName : String? = nil
        
        if notification.userInfo?["selectedDivision"] != nil {
            let selectedDivision = notification.userInfo?["selectedDivision"] as! Int // the picker row #
            let divisionList = Public.Var.allDivisions[countryName]             // list of all divisions of the country
            if divisionList != nil {
                divisionName = divisionList?[selectedDivision]
            }
        }
        Public.saveToUserDefaultsTheValue(divisionName as String?, K.divisionKey)   // if nil will delete
        
        let path = IndexPath(row: 0, section: 0)
        self.tableView.reloadRows(at: [path], with: UITableViewRowAnimation.top)
        showPickerRow = false
        tableView.reloadData()

    }
    
    func catchCancelNotification (notification: Notification) {
        
        showPickerRow = false
        //let path = IndexPath(row: 1, section: 0)
        self.tableView.reloadData()
    }
    
    
    func catchPickerLocationsUpdatedNotification (notification: Notification) {
        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)

    }
    
    // MARK: UIPickerView functions
    
    // Number of pickers in the pickerview. There are 2 - one for countries, one for divisions (e.g. states)
    func numberOfComponents(in: UIPickerView) -> Int {
        return 2
    }
    
    // Number of rows of data in the (country or division) picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var numberOfRows = 0
        
        switch component {
        case 0:
            numberOfRows = Public.Var.allCountries.count                             // count = # of countries
            //print("allCountries = \(Public.Var.allCountries)")
        case 1:
            let countryRow = pickerView.selectedRow(inComponent: 0)     // # of selected Country row
            let countryName = Public.Var.allCountries[countryRow]       // name of selected country
            print("country name = \(countryName)")
            let divisions : [String]? = Public.Var.allDivisions[countryName]
            if divisions != nil {   // list of divisions for the country
                numberOfRows = (divisions?.count)!
            }
            else {
                numberOfRows = 0
            }
           //print("allDivisions = \(Public.Var.allDivisions)")
        default:
            break
    
        }
        print("number of rows for component = \(component), \(numberOfRows)")
        return numberOfRows
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var rowTitle = ""
        
            switch component {
            case 0:
                let sortedCountries = Public.Var.allCountries
                rowTitle = sortedCountries[row]
                break
            case 1:
                
                let countryRow = pickerView.selectedRow(inComponent: 0)
                rowTitle = divisionNameOfRow(row, usingCountryRow: countryRow, usingDivisionDict: Public.Var.allDivisions )
                    
            default:
                break
                
            }
        //}
        return rowTitle
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            pickerView.reloadComponent(1)
            break
        case 1:
            break
        default:
            break
        }
    }
    
    
    // MARK: UITableView functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        var height:CGFloat = UITableViewAutomaticDimension
        
        if indexPath.row == 1 {
            if showPickerRow == true { height = 110.0 } else {height = 0.0}
        }
        
        return height
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 3
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        switch indexPath.row{
        case 0:
            
            // need to handle first time when location not yet available
            
            cell = tableView.dequeueReusableCell(withIdentifier: K.locationCellName, for: indexPath) as! LocationTableViewCell
            if Public.getValueFromUserDefaultsForKey(K.countryKey)  != nil {
                let country = Public.getValueFromUserDefaultsForKey(K.countryKey) as! String
                let division = Public.getValueFromUserDefaultsForKey(K.divisionKey) as? String
                var cellText = ""
                if division == nil || division == "" {
                    cellText = country
                } else {
                    cellText = division! + ", " + country
                }
                (cell as! LocationTableViewCell).currentLocation.text = cellText
                
            }
            else {
                (cell as! LocationTableViewCell).currentLocation.text = K.defaultLocationTextInCell
            }
            
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: K.pickerCellName, for: indexPath) as! PickerTableViewCell
            (cell as! PickerTableViewCell).picker.reloadAllComponents()
             if showPickerRow == false {
                cell.isHidden = true
            }


        case 2:
            
            cell = tableView.dequeueReusableCell(withIdentifier: K.userNameCellName, for: indexPath) as! NameTableViewCell
            let savedName = SharedServices.sharedInstance.getValueFromUserDefaultsForKey(key: K.userNameKey) as? String
            (cell as! NameTableViewCell).userName.text = savedName
            
        default:    // should never happen
            cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        }
        
        return cell
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true)
    
        switch indexPath.row {
        case 0:
            
            showPickerRow = true
            self.tableView.reloadData()
            
        default:
            break
        }
    
    
    }
    
    
    // MARK helper functions
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        SharedServices.sharedInstance.saveToUserDefaultsTheValue(value: textField.text! as String, forKey: K.userNameKey)
    }
    
    
    func countryNameOfRow(_ ofTitleRow: Int, usingCountriesArray: [String] ) -> String {
        var name = ""
        
        if usingCountriesArray.count > 0 {
            
            //let sortedCountries = Array(usingLocationDict.keys).sorted(by: <)
            name = usingCountriesArray[ofTitleRow]     // selected Country
            
        }
        
        return name
    }
    
    func divisionNameOfRow(_ ofTitleRow: Int, usingCountryRow: Int, usingDivisionDict: [String: [String]] ) -> String {
        var name = ""
        
        let countryRow = usingCountryRow
        let countryName = countryNameOfRow(countryRow, usingCountriesArray: Public.Var.allCountries)
        if usingDivisionDict[countryName] != nil {        // there are divisions assoc. with the country
           
            name = (Public.Var.allDivisions[countryName]?[ofTitleRow])!
            
        }
        
        return name
    }
    
    
}

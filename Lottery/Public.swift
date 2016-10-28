//
//  Shared.swift
//  Lottery
//
//  Created by Peter Brooks on 10/2/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import UIKit

public class Public: NSObject {
    
    static let sharedInstance = Public()    // set up shared instance class
    private override init() {}                      // ensure noone will init
    
        // Shared method names to improve readibility
        
        static let  saveToUserDefaultsTheValue          =   SharedServices.sharedInstance.saveToUserDefaultsTheValue
        static let  getValueFromUserDefaultsForKey      =   SharedServices.sharedInstance.getValueFromUserDefaultsForKey
        static let  setActivityIndicator                =   SharedServices.sharedInstance.setActivityIndicator
        static let  stateNameFromAbbreviation           =   SharedServices.sharedInstance.stateNameFromAbbreviation
        static let  getLocationAndGetGamesFromFirebase  =   NetworkServices.sharedInstance.getLocationAndGetGamesFromFirebase
        static let  getGamesFromFirebase                =   NetworkServices.sharedInstance.getGamesFromFirebase
        static let  getPickerLocationsFromFirebase     =   NetworkServices.sharedInstance.getPickerLocationsFromFirebase

    
    struct Var {
        
        static var lotteryLocation = [
            "abbrev"            : "",
            "currencyName"      : "",
            "currencySymbol"    : ""]

        static var allCountries = [String]()
        static var allDivisions = [String:[String]]()
        
    }
    
}

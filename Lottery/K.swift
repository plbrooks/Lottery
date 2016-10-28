//
//  Constants.swift
//  Lottery
//
//  Created by Peter Brooks on 9/13/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import UIKit

class K: NSObject {
    
    static let descrip = "DESCRIPTION"
    
    
    // MARK: UserDefault keys
    static let countryKey       = "LotteryCountry"
    static let divisionKey      = "LotteryDivision"
    
    // MARK: Firebase paths
    static let allCountriesPath             = "/countries/"
    static let oneCountryPath               = "/countries/COUNTRY/"
    static let allDivisionsPath             = "/divisions/"
    static let oneCivisionPath              = "/divisions/COUNTRY/DIVISION/"
    static let allGamesInDivionPath         = "/games/COUNTRY/division/DIVISION/games/"
    static let allGamesInCountryPath        = "/games/COUNTRY/games/"
    static let whereToPlayPath              = "/wheretoplay/COUNTRY/"
    static let COUNTRY                      = "COUNTRY"
    static let DIVISION                     = "DIVISION"
    
    
    
    static let segmentNumKey   = "SegmentNum"
    static let userNameKey     = "UserName"

    
    // MARK: UITableViewCell names
    static let locationCellName = "LocationTableViewCell"
    static let pickerCellName   = "PickerTableViewCell"
    static let userNameCellName = "NameTableViewCell"
    
    static let defaultLocationTextInCell = "Your Location"
    
    
    // MARK: Notification names
    static let saveNotification                 = "SaveButtonPressed"
    static let cancelNotification               = "CancelButtonPressed"
    static let awakeNotification                = "Awake"
    static let pickerLocationsUpdatedNotification      = "LocationUpdated"
    static let allGamesNotification             = "AllGames"
    static let getAllLocationsNotification      = "GetAllLocations"
    
    // MARK: Notification info keys
    static let gamesDictionary                  = "gamesDictionary"

    
    // Location services constants
    static let US               = "US"
    static let UnitedStates     = "United States"
    static let stateNames: [String: String] = [
        "AL":"Alabama",
        "AK":"Alaska",
        "AZ":"Arizona",
        "AR":"Arkansas",
        "CA":"California",
        "CO":"Colorado",
        "CT":"Connecticut",
        "DE":"Delaware",
        "DC":"District of Columbia",
        "FL":"Florida",
        "GA":"Georgia",
        "HI":"Hawaii",
        "ID":"Idaho",
        "IL":"Illinois",
        "IN":"Indiana",
        "IA":"Iowa",
        "KS":"Kansas",
        "KY":"Kentucky",
        "LA":"Louisiana",
        "ME":"Maine",
        "MD":"Maryland",
        "MA":"Massachusetts",
        "MI":"Michigan",
        "MN":"Minnesota",
        "MS":"Mississippi",
        "MO":"Missouri",
        "MT":"Montana",
        "NE":"Nebraska",
        "NV":"Nevada",
        "NH":"New hampshire",
        "NJ":"New jersey",
        "NM":"Mew mexico",
        "NY":"New york",
        "NC":"North carolina",
        "ND":"North dakota",
        "OH":"Ohio",
        "OK":"Oklahoma",
        "OR":"Oregon",
        "PA":"Pennsylvania",
        "RI":"Rhode island",
        "SC":"South carolina",
        "SD":"South dakota",
        "TN":"Tennessee",
        "TX":"Texas",
        "UT":"Utah",
        "VT":"Vermont",
        "VA":"Virginia",
        "WA":"Washington",
        "WV":"West virginia",
        "WI":"Wisconsin",
        "WY":"Wyoming"]


    
}

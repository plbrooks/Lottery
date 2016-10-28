//
//  NetworkServices.swift
//  Lottery
//
//  Created by Peter Brooks on 10/19/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftLocation
import Firebase
import MapKit



class NetworkServices: NSObject {
    
    // MARK: Vars
    
    static let sharedInstance = NetworkServices()   // set up shared instance class
    private override init() {}                      // ensure noone will init

    
    // set up Firebase vars
    var ref: FIRDatabaseReference! = {
       return FIRDatabase.database().reference()
    }()
    
    
    
    // MARK: funcs
    
    func getLocationAndGetGamesFromFirebase() throws {
        var getError: Error?
        
        var _ = Location.getLocation(withAccuracy: .city, frequency: .oneShot, timeout: 30, onSuccess: { (loc) in   // get location coordinates
            
            var _ = Location.reverse(coordinates: loc.coordinate, onSuccess: { foundPlacemark in    // get location country and division
                
                if foundPlacemark.country != nil {
                    
                    //self.ref = FIRDatabase.database().reference()
                    
                    let refKey = self.createRefKey(fromCountryPath: K.oneCountryPath, usingCountry: foundPlacemark.country, fromDivisionPath: nil, usingDivision: nil)
                    
                    self.ref.child(refKey!).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() {  // country is in Firebase
                            
                            self.saveCountryFrom(placemark: foundPlacemark) // only save if country found in firebase

                            let refKey = self.createRefKey(fromCountryPath: K.oneCountryPath, usingCountry: foundPlacemark.country, fromDivisionPath:K.oneCivisionPath, usingDivision:foundPlacemark.administrativeArea)
                            
                            self.ref.child(refKey!).observeSingleEvent(of: .value, with: { (snapshot) in
                                if snapshot.exists() {  // division exists
                                    self.saveDivisionFrom(placemark: foundPlacemark)
                                }   // if divison does not exist don't save it
                                
                                do {    // regardless of whether division exists, get games
                                    try self.getGamesFromFirebase()
                                } catch {
                                    print("error")
                                }
                                
                                
                            }) { (error) in
                                getError = error
                            }
                            
                        } else {
                            // country does not exist
                            print("error")
                        }
                        
                    }) { (error) in
                        getError = error                    }
                }

            }, onError: { error in
                getError = error
            })

        }, onError: { location, error in
            getError = error
        })
        
        if getError != nil {throw getError!}
    }

    
    
    func saveCountryFrom(placemark: CLPlacemark) {
        
        Public.saveToUserDefaultsTheValue(placemark.country! as String, K.countryKey)
        
    }

    func saveDivisionFrom(placemark: CLPlacemark) {
        
        Public.saveToUserDefaultsTheValue(placemark.administrativeArea! as String, K.divisionKey)
        
    }


    func getGamesFromFirebase() throws {
        
        var getError: Error?
        
        //ref = FIRDatabase.database().reference()
        
        let country = Public.getValueFromUserDefaultsForKey(K.countryKey) as? String
        let division = Public.getValueFromUserDefaultsForKey(K.divisionKey) as? String
        
        // country has to exist. division may exist or be nil
        
        let refKey = self.createRefKey(fromCountryPath: K.allGamesInCountryPath, usingCountry: country, fromDivisionPath:K.allGamesInDivionPath,  usingDivision:division)
        
        
        ref.child(refKey!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                
                if snapshot.key == K.descrip {
                    
                    let game = snapshot.value! as! NSDictionary
                    Public.Var.lotteryLocation["abbrev"] = game["Abbrev"] as? String
                    Public.Var.lotteryLocation["currencyName"] = game["Currency Name"] as? String
                    Public.Var.lotteryLocation["currencySymbol"] = game["Currency Symbol"] as? String
                    
                } else {
                    
                    let info = [K.gamesDictionary : snapshot.value]
                    NotificationCenter.default.post(name: Notification.Name(K.allGamesNotification), object: nil, userInfo: info)
                    
                }
   
                
            } else {
                print("get games snapshot does not exist error")
            }
            
        }) { (error) in
            getError = error
        }
        
        if getError != nil {throw getError!}
    }

    
    func getPickerLocationsFromFirebase() throws {  // first inititialization
        
        var getError: Error?
        
        //ref = FIRDatabase.database().reference()
        
        let refKey = K.allCountriesPath // get all countries
        
        ref.child(refKey).observeSingleEvent(of: .value, with: { (snapshot) in
            
                if snapshot.exists() {
                    
                    let countries = snapshot.value as! NSDictionary
                    for (countryName, _) in countries {
                        Public.Var.allCountries.append(countryName as! String)
                    }
                   Public.Var.allCountries.sort()
                    
                    let refKey = K.allDivisionsPath // get all divisions of all countries
                    self.ref.child(refKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.exists() {
                            
                            let allCountrieDivisions = snapshot.value as! NSDictionary
                            for (country, children) in allCountrieDivisions {
                                
                                let divisionsPlusChildren = children as! NSDictionary
                                
                                var divisions = [String]()
                                for (divisionName, _) in divisionsPlusChildren {
                            
                                    divisions.append(divisionName as! String)
                                }
                                divisions.sort()
                                Public.Var.allDivisions[country as! String] = divisions
                            }
                        } else {
                            
                            // error but no error just snapshot does not exist
                            print("error")
                            
                            return
                        }
                        
                    }) { (error) in
                        getError = error
                    }

                    
                } else {
                    
                    // error but no error just snapshot does not exist
                    
                    return
                }
                
            }) { (error) in
                getError = error
            }
            
        if getError != nil {throw getError!}
        
    }

    func getMapLocationsFromFirebase() throws {  // first inititialization
        
        
        //ref = FIRDatabase.database().reference()
        
        let country = Public.getValueFromUserDefaultsForKey(K.countryKey) as? String
        let division = Public.getValueFromUserDefaultsForKey(K.divisionKey) as? String
        var refKey = ""
        if division == nil {
            refKey = self.createRefKey(fromCountryPath: K.whereToPlayCountryPath, usingCountry: country, fromDivisionPath:K.allGamesInDivionPath,  usingDivision:division)!
        } else {
            refKey = self.createRefKey(fromCountryPath: K.whereToPlayDivisionPath, usingCountry: country, fromDivisionPath:K.allGamesInDivionPath,  usingDivision:division)!
        }
        
        ref.child("wheretoplay/United States/Massachusetts/").observe(.value, with: { (snapshot) -> Void in
            
            
            if snapshot.exists() {
                
                let data = snapshot.value as! [String: [String: String]]
                for (_, whereToPlayData) in data {
                    let annotation = MKPointAnnotation()
                    print("annotation title = \(annotation.title)")
                    let lat = Double(whereToPlayData["lat"]!)
                    let long = Double(whereToPlayData["long"]!)
                    let coordinate  = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                    annotation.coordinate = coordinate
                    annotation.title = whereToPlayData["name"]
                    annotation.subtitle = whereToPlayData["address"]!+"\n"+whereToPlayData["city"]!+"\n"+whereToPlayData["state"]!+" "+whereToPlayData["zip"]!
                    
                    Public.Var.annotations.append(annotation)
                    //send notification?
                }
                
            } else {
                
                print("no snapshot")
                return
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
  
    
    
    func createRefKey(fromCountryPath: String, usingCountry:String?, fromDivisionPath: String?, usingDivision: String?) -> String? {
        
        var refKey: String?

        // set up country and division vars
        var country: String? = nil
        var division: String? = nil
        
        switch (usingCountry) {
        
        case nil:
            
            if let storedCountry = Public.getValueFromUserDefaultsForKey(K.countryKey) as! String? {
                country = storedCountry
                if let storedDivision = Public.getValueFromUserDefaultsForKey(K.divisionKey) as! String? {
                    division = storedDivision
                }
            }
            
        default:
            
            country = usingCountry
            division = usingDivision    // could be nil that is OK
            if country == K.UnitedStates && division?.characters.count == 2 {
                division = Public.stateNameFromAbbreviation(division)
            }
            
        }
        
        if country != nil {
            
            refKey = substituteKeyInString(fromCountryPath, key: K.COUNTRY, value: country!)
            if division != nil {
                
                refKey = substituteKeyInString(fromDivisionPath!, key: K.COUNTRY, value: country!)
                refKey = substituteKeyInString(refKey!, key: K.DIVISION, value: division!)
                
            }
        }
        return refKey
    }
    
    
    //  Update a string STRING by replacing contents KEY that is found in the string with the contents VALUE

    func substituteKeyInString(_ string: String, key: String, value: String) -> String? {
        if (string.range(of: key) != nil) {
            return string.replacingOccurrences(of: key, with: value)
        } else {
            return string
        }
    }

}

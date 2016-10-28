//
//  SharedServices.swift
//  Lottery
//
//  Created by Peter Brooks on 9/26/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import Foundation
import UIKit
import MapKit


// MARK: All non-network shared services

class SharedServices: NSObject {
    static let sharedInstance = SharedServices()    // set up shared instance class
    private override init() {}                      // ensure noone will init
    
    func saveToUserDefaultsTheValue(value: Any?, forKey: String) {
        
        let defaults = UserDefaults.standard
        
        print("save value = \(value)")
        
        switch value {
        case nil:
            
            defaults.removeObject(forKey: forKey)
            
        case let someString as String:
            
            if (someString) != "" {
                
                defaults.set(someString, forKey: forKey)
                
            } else {
                
                defaults.removeObject(forKey: forKey)
                
            }
            
        case let someInt as Int:
            
            defaults.set(someInt, forKey: forKey)
            
        case let somePlacemark as CLPlacemark:
            
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: somePlacemark)
            defaults.set(encodedData, forKey: forKey)
            
        default:
            defaults.removeObject(forKey: forKey)
        }
    }
    
    func getValueFromUserDefaultsForKey(key: String) -> Any? {
        
        let defaults = UserDefaults.standard
        let value = defaults.object(forKey: key)
        
        print("get value = \(value)")
        
        
        switch value {
        case nil:
            return nil
        case let someString as String:
            
            return someString
            
        case let someInt as Int:
            
            return someInt
            
        case let someData as Data:
            
            var decodedLocation: CLPlacemark?
            decodedLocation = NSKeyedUnarchiver.unarchiveObject(with: someData) as! CLPlacemark?
            return decodedLocation
            
        default:
            
            return nil
            
        }
        
    }
    
    
    func deleteFromDefaultsForKey(key: String) {
    
    }
    
    func stateNameFromAbbreviation(abbrev: String?) -> String? {
        
        var name: String? = nil
        
        if !(abbrev?.isEmpty)! && K.stateNames[abbrev!] != nil {
            name = K.stateNames[abbrev!]
        }
        
        return name
        
    }
    
    
    
    // MARK: Error Processing
    
    // Convert error codes to error messages. Add in variable text as needed.
    
    /*func errorMessage(err: ErrorType) -> String {
     
     var errMessage = ""
     
     switch err {
     
     case Status.codeIs.accessSavedData (let code, let text):
     errMessage = Status.textIs.accessSavedData
     errMessage = substituteKeyInString(errMessage, key: "STATUSCODE", value: String(code))!
     errMessage = substituteKeyInString(errMessage, key: "TEXT", value: text)!
     
     case Status.codeIs.noFlickrDataReturned:
     errMessage = Status.textIs.noFlickrDataReturned
     
     case Status.codeIs.couldNotParseData:
     errMessage = Status.textIs.couldNotParseData
     case Status.codeIs.pinNotFound:
     errMessage = Status.textIs.pinNotFound
     
     case Status.codeIs.flickrStatus(let statusCode):
     errMessage = Status.textIs.flickrStatus
     errMessage = substituteKeyInString(errMessage, key: "STATUSCODE", value: String(statusCode))!
     
     case Status.codeIs.network(let type, let error):
     errMessage = Status.textIs.network
     errMessage = substituteKeyInString(errMessage, key: "TYPE", value: type)!
     errMessage = substituteKeyInString(errMessage, key: "STATUSCODE", value: String(error.code))!
     errMessage = substituteKeyInString(errMessage, key: "TEXT", value: error.localizedDescription)!
     
     case Status.codeIs.nserror(let type, let error):
     errMessage = Status.textIs.nserror
     errMessage = substituteKeyInString(errMessage, key: "TYPE", value: type)!
     errMessage = substituteKeyInString(errMessage, key: "STATUSCODE", value: String(error.code))!
     errMessage = substituteKeyInString(errMessage, key: "TEXT", value: error.localizedDescription)!
     
     default:    // no error
     errMessage = Status.textIs.noError
     }
     return errMessage
     
     }
     
     
     //  Update a string STRING by replacing contents KEY that is found in the string with the contents VALUE
     
     func substituteKeyInString(string: String, key: String, value: String) -> String? {
     if (string.rangeOfString(key) != nil) {
     return string.stringByReplacingOccurrencesOfString(key, withString: value)
     } else {
     return string
     }
     }*/
    
    
    // Show an alert. Message is from message list in the common "Status" file
    
    func showAlert (error: Error, title: String) {
     let vc = presentingVC()
         //let message = errorMessage(error)
        let message = "Error"
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(OKAction)
        if vc!.presentedViewController == nil {
            DispatchQueue.main.async( execute: {
                vc!.present(alertView, animated: true, completion: nil)
            })
        }
    }
    
    // Map activity indicator setup
    
    func setActivityIndicator(option: String, mapView: MKMapView, activityIndicator: UIActivityIndicatorView ) {
        switch(option) {
        case "START":
            
            mapView.alpha = 0.25
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            
        case "FINISH":    // FINISH
            
            mapView.alpha = 1.0
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            
        default:
            
            break
            
         }
     }
    
    
    // Find current VC. Used in func ShowAlert to get the present VC
    
    func  presentingVC() -> UIViewController? {
     var topController = UIApplication.shared.keyWindow?.rootViewController
     if topController != nil {
     while let presentedViewController = topController!.presentedViewController {
     topController = presentedViewController
     }
     }
     return topController
     }
}




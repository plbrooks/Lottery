//
//  LocationViewController.swift
//  Lottery
//
//  Created by Peter Brooks on 10/9/16.
//  Copyright © 2016 Peter Brooks. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class WhereToPlayViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    //var ref: FIRDatabaseReference!
    //var refHandleWhereToPlay: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //ref = FIRDatabase.database().reference()
        mapView.delegate = self
        
        //let gestureRecognizer = UITapGestureRecognizer(target: self, action:Selector(("handleTap:")))
        //gestureRecognizer.delegate = self
        //mapView.addGestureRecognizer(gestureRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        do  {
            try Public.getMapLocationsFromFirebase()
        } catch {
            print("error = \(error.localizedDescription)")
        }
        
        //self.mapView.addAnnotations(Public.Var.annotations)
        //print("annotations = \(Public.Var.annotations))")
        //loadDataFromFirebase()
        
        // Do some map housekeeping - set span, center, etc.
        mapView.userTrackingMode = .follow
        
        //let location = CLLocationCoordinate2D(latitude: selectedPin!.latitude as Double, longitude:selectedPin!.longitude as Double)
        let span = MKCoordinateSpanMake(2.0,2.0)                        // set reasonable granularity
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate , span: span ) // center map
        mapView.setRegion(region, animated: true)                  // show the map

    }
    
    
    /*func loadDataFromFirebase() {  // first inititialization
        
        let refKey = "wheretoplay/United States/Massachusetts/"
        
        refHandleWhereToPlay = self.ref.child(refKey).observe(.value, with: { (snapshot) -> Void in
            

            if snapshot.exists() {
                
                let data = snapshot.value as! [String: [String: String]]
                var annotations = [MKPointAnnotation]()
                for (name, whereToPlayData) in data {
                    
                    let annotation = MKPointAnnotation()
                    let lat = Double(whereToPlayData["lat"]!)
                    let long = Double(whereToPlayData["long"]!)
                    let coordinate  = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                    annotation.coordinate = coordinate
                    annotation.title = whereToPlayData["name"]
                    annotation.subtitle = whereToPlayData["address"]!+"\n"+whereToPlayData["city"]!+"\n"+whereToPlayData["state"]!+" "+whereToPlayData["zip"]!

                    annotations.append(annotation)
                }
                annotations.removeAll()
                self.mapView.addAnnotations(annotations)
                print("annotations = \(annotations)")
                
            } else {
                
                print("no snapshot")
                return
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }*/
    
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinOnMap = mapView.dequeueReusableAnnotationView(withIdentifier: "PinOnMap") as? MKPinAnnotationView
        if pinOnMap == nil {
            pinOnMap = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapPin")
            pinOnMap?.canShowCallout = true
            
            let subtitleView = UILabel()
            subtitleView.font = subtitleView.font.withSize(12)
            subtitleView.numberOfLines = 0
            subtitleView.text = annotation.subtitle!
            pinOnMap!.detailCalloutAccessoryView = subtitleView
        }
        else {
            pinOnMap!.annotation = annotation
        }
        return pinOnMap
    }
        
    
    func mapViewDidStartRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        Public.setActivityIndicator("START", mapView, activityIndicator)
        
        
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        
        Public.setActivityIndicator("FINISH", mapView, activityIndicator)
    }
    
}

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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        NotificationCenter.default.addObserver(forName: Notification.Name(K.whereToPlayLocationsNotification), object: nil, queue: nil, using: whereToPlayNotification)
        
    }
    

    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func whereToPlayNotification (notification: Notification) {
        
        self.mapView.addAnnotations(Public.Var.annotations)
        
    }

    
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        do  {
            mapView.removeAnnotations(mapView.annotations)
            try Public.getMapLocationsFromFirebase()
        } catch {
            print("error = \(error.localizedDescription)")
        }
        
    }
    
    
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinOnMap = mapView.dequeueReusableAnnotationView(withIdentifier: "PinOnMap") as? MKPinAnnotationView
        
        if pinOnMap == nil {
            pinOnMap = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapPin")
            if annotation is MKUserLocation {
                pinOnMap?.pinTintColor = UIColor.purple
            }
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

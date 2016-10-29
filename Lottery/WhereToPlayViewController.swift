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
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        do  {
            mapView.removeAnnotations(mapView.annotations)
            try Public.getMapLocationsFromFirebase()
            print("annotations are \(Public.Var.annotations)")
        } catch {
            print("error = \(error.localizedDescription)")
        }
        
        self.mapView.addAnnotations(Public.Var.annotations)
        
        // Do some map housekeeping - set span, center, etc.
        mapView.userTrackingMode = .follow
        let span = MKCoordinateSpanMake(2.0,2.0)                        // set reasonable granularity
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate , span: span ) // center map
        mapView.setRegion(region, animated: true)                  // show the map

    }
    

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
            //pinOnMap?.pinTintColor = UIColor.purple
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

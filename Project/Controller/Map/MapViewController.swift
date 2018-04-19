//
//  MapViewController.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/19/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var trainerAndPartnerLocations =  [CLLocationCoordinate2D?]()
    
    private var appStartedForTheFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.disableKeybordWhenTapped = true
        initializeLocationManager()
        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = true
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinates from the manager
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            mapView.setRegion(region, animated: true)
            
            mapView.removeAnnotations(mapView.annotations)
            
            if trainerAndPartnerLocations.count > 0 {
                
                for location in trainerAndPartnerLocations{
                    let partnerAnnotation = MKPointAnnotation()
                    partnerAnnotation.coordinate = location!
                    partnerAnnotation.title = "Partner Location"
                    mapView.addAnnotation(partnerAnnotation)
                }
                
            }
            
            //            let annotation = MKPointAnnotation()
            //            annotation.coordinate = userLocation!
            //            annotation.title = "Trainer Location"
            //            mapView.addAnnotation(annotation)
            
        }
        
    }

}

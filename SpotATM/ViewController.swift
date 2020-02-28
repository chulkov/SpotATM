//
//  ViewController.swift
//  SpotATM
//
//  Created by Max on 28/02/2020.
//  Copyright © 2020 chulkov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate{
    // MARK: Properties
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.delegate = self
        }
    }
    var locationManager = CLLocationManager(){
        didSet{
            locationManager.delegate = self
        }
    }
    private var currentLocation: CLLocation?
    
    var bunchOfPartners = Partner(){
        didSet{
            addAnnotations(partners: bunchOfPartners!)
        }
    }
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)

        showPins()
        
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            showPins()
        }
    }
    fileprivate func showPins() {
        Networking().getPartners(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude, radius: mapView.currentRadius() ) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let bunchOfPartners):
                self.bunchOfPartners = bunchOfPartners
                //print(bunchOfPartners)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        print("didUpdateLocations")
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                mapView.setRegion(viewRegion, animated: false)
            }
        }
        
    }


    
    func addAnnotations(partners: Partner){
        guard let partnersInformation = partners.items else {
            return
        }
        for partner in partnersInformation{
            let CLLCoordType = CLLocationCoordinate2D(latitude: partner.location.latitude, longitude: partner.location.longitude)
            let anno = MKPointAnnotation();
            anno.coordinate = CLLCoordType;
            anno.title = partner.partnerName
            mapView.addAnnotation(anno);
        }
    }
    
    
    
    // MARK: IBActions
    
    @IBAction func zoomIn(_ sender: UIButton) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }
    @IBAction func zoomOut(_ sender: UIButton) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func showCurrentLocation(_ sender: UIButton) {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
    }
    
}

extension MKMapView {

    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }

    func currentRadius() -> Int {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        print(centerLocation.distance(from: topCenterLocation))
        print(Int(centerLocation.distance(from: topCenterLocation)))
        let radius = Int(centerLocation.distance(from: topCenterLocation))
        
        return radius
    }

}

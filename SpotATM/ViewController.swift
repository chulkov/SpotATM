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
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate{
    
    // MARK: IBOutlets
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.delegate = self
        }
    }
    
    // MARK: Properties
    var locationManager = CLLocationManager(){
        didSet{
            locationManager.delegate = self
        }
    }
    private var currentLocation: CLLocation?
    lazy var coreDataStack = CoreDataStack(modelName: "SpotATM")
    var fetchRequest: NSFetchRequest<Partner>?
    var partners: [Partner] = []
    var asyncFetchRequest: NSAsynchronousFetchRequest<Partner>?
    var isFirstLoad = true
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
        
        
        mapView.showsUserLocation = true
        
        //////////////////////
//        importJSONDataToCoreData()
//        fetchDataToMapView()
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            //showPins()
        }
    }


    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
        if mapView.isUserLocationVisible, mapView.currentRadius() < 3000, isFirstLoad{
            isFirstLoad = false
            importJSONDataToCoreData()
        }
        importJSONDataToCoreData()
       
    }
    // MARK: - CLLocationManagerDelegate
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        defer { currentLocation = locations.last }
//        print("didUpdateLocations")
//        if currentLocation == nil {
//            // Zoom to user location
//            if let userLocation = locations.last {
//                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
//                mapView.setRegion(viewRegion, animated: false)
//
//            }
//        }
//
//    }
    
    
    
    fileprivate func fetchDataToMapView() {
        let partnerFetchRequest: NSFetchRequest<Partner> = Partner.fetchRequest()
        fetchRequest = partnerFetchRequest
        
        asyncFetchRequest = NSAsynchronousFetchRequest<Partner>(fetchRequest: partnerFetchRequest) {
            [unowned self] (result: NSAsynchronousFetchResult) in
            guard let partners = result.finalResult else {
                return
            }
            
            self.partners = partners
            self.addAnnotations()
        }
        
        do {
            guard let asyncFetchRequest = asyncFetchRequest else {
                return
            }
            try coreDataStack.managedContext.execute(asyncFetchRequest)
            // Returns immediately, cancel here if you want
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func addAnnotations(){
        // TODO: check for duplicates(?)
        if mapView.annotations.count < partners.count{
            for partner in partners{
                let CLLCoordType = CLLocationCoordinate2D(latitude: partner.latitude, longitude: partner.longitude)
                let anno = MKPointAnnotation();
                anno.coordinate = CLLCoordType;
                anno.title = partner.name
                mapView.addAnnotation(anno);
            }
        }
        
       // mapView.showAnnotations(mapView.annotations, animated: true)
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
        let radius = Int(centerLocation.distance(from: topCenterLocation))
        
        return radius
    }
    
}



// MARK - Data loading
extension ViewController {
    func importJSONDataToCoreData(){
        Networking().getPartners(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude, radius: mapView.currentRadius() ) { result in
            switch result {
            case .failure(let error):
                print("URLError: \(error)")
            case .success(let jsonData):
                print("URLSuccess")
                let jsonDict = try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: Any]

                let jsonArray = jsonDict["payload"] as! [[String: Any]]
                for jsonDictionary in jsonArray {

                    let id = jsonDictionary["externalId"] as? String
                    let name = jsonDictionary["partnerName"] as? String

                    let location = jsonDictionary["location"] as! [String: Double]
                    let latitude = location["latitude"]
                    let longitude = location["longitude"]

                    let workHours = jsonDictionary["workHours"] as? String
                    let phones = jsonDictionary["phones"] as? String
                    let fullAddress = jsonDictionary["fullAddress"] as? String



                    let partner = Partner(context: self.coreDataStack.managedContext)
                    partner.id = id
                    partner.name = name
                    partner.latitude = latitude ?? 0.0
                    partner.longitude = longitude ?? 0.0
                    partner.workHours = workHours
                    partner.phones = phones
                    partner.fullAddress = fullAddress
                }

                self.coreDataStack.saveContext()
            }
        }
        fetchDataToMapView()
    }
    
}

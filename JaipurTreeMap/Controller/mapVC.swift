//
//  mapVC.swift
//  JaipurTreeMap
//
//  Created by Nirbhay Singh on 04/12/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Firebase
import JGProgressHUD
class mapVC: UIViewController,CLLocationManagerDelegate{
    //MARK:Global Variables
    let locationManager = CLLocationManager()
    var coords:CLLocationCoordinate2D!
    let hud = JGProgressHUD.init()
    let camera = GMSCameraPosition.camera(withLatitude: 60, longitude:60, zoom: 16.0)
    lazy var mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocation()
        // Do any additional setup after loading the view.
    }
    
    func setUpLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        hud.show(in: self.view,animated: true)
        locationManager.startUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("called")
        let location:CLLocation = locations[0]
        coords = location.coordinate
        print(coords.longitude)
        locationManager.stopUpdatingLocation()
        hud.dismiss()
        refreshMap()
    }
    
    override func loadView() {
               mapView.isMyLocationEnabled = true
               do {
                 mapView.mapStyle = try GMSMapStyle(jsonString: mapJSON)
               } catch {
                 NSLog("One or more of the map styles failed to load. \(error)")
               }
               self.view = mapView
    }
    func refreshMap(){
        let cam = GMSCameraPosition.camera(withLatitude: coords.latitude, longitude:coords.longitude, zoom: 16.0)
        mapView.camera = cam
        populateMap()
    }
    func populateMap(){
        let ref = Database.database().reference().child("trees-node")
        _ = ref.observe(DataEventType.value, with: { (snapshot) in
            let reports = snapshot.value as! [String:AnyObject]
            let markerImg = UIImage(named: "tree")
            for report in reports{
                print(report)
                let lat = report.value["location-lat"] as! Double
                let lon = report.value["location-lon"] as! Double
                let email = report.value["user-email"] as! String
                let species = report.value["species"] as! String
                let diameter = report.value["diameter"] as! String
                let height = report.value["height"] as! String
                let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let marker = GMSMarker(position: position)
                marker.title = species
                marker.icon = markerImg
                marker.snippet = "Diameter:"+diameter+"m\n Height:"+height+"m\n Uploaded by:" + email
                marker.map = self.mapView
            }
        })

    }

}

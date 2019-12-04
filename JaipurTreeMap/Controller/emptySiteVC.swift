//
//  emptySiteVC.swift
//  JaipurTreeMap
//
//  Created by Nirbhay Singh on 04/12/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import JGProgressHUD
import CoreLocation
import GoogleMaps
class emptySiteVC: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var addressLbl: UILabel!
    
    var coord:CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    let hud = JGProgressHUD.init()
    override func viewDidLoad() {
        super.viewDidLoad()
            setUpLocation()
        
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
           coord = location.coordinate
           let coordinate:CLLocationCoordinate2D = location.coordinate
           locationManager.stopUpdatingLocation()
           let geocoder = GMSGeocoder()
           geocoder.reverseGeocodeCoordinate(coordinate, completionHandler:{(resp,error)  in
               self.hud.dismiss()
               if(error != nil || resp==nil ){
                   showAlert(msg: "You may have connectivity issues :"+error!.localizedDescription)
               }else{
                   print(resp?.results()?.first as Any)
                   self.addressLbl.text = resp?.results()?.first?.lines![0]
               }
               
           })
       }
    

}

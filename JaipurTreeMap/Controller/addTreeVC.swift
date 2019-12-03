//
//  addTreeVC.swift
//  JaipurTreeMap
//
//  Created by Nirbhay Singh on 29/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import CoreLocation
import JGProgressHUD
import GoogleMaps
import ARKit
import Firebase
import SearchTextField

class addTreeVC: UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
    
    //MARK:GLOBAL VARS
    var thisUser:UserClass!
    let species:[String]=["Jand","Desert Date","Jujube","Ailanthus Excelsa","Tecomella"]
    let locationManager = CLLocationManager()
    let hud = JGProgressHUD()
    let imagePicker = UIImagePickerController()
    var imgData:Data!
    var coord:CLLocationCoordinate2D!
    //MARK:IB OUTLETS
    @IBOutlet weak var searchTxtBox: SearchTextField!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var heightTxtBox: UITextField!
    @IBOutlet weak var diameterTextBox: UITextField!
    //MARK:VIEWDIDLOAD
    override func viewDidLoad() {
        imagePicker.delegate = self
        submitBtn.layer.cornerRadius = 15
        setUpLocation()
        setUpSearchBox()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        super.viewDidLoad()
    }
    

    
    
    //MARK:LOCATION METHODS
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
    
    //MARK:IB ACTIONS
    @IBAction func cameraBtn(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let locHud = JGProgressHUD.init()
        let species = searchTxtBox.text
        let height = heightTxtBox.text
        let diameter = diameterTextBox.text
        if(height==""||diameter==""){
            showAlert(msg: "You can't leave fields empty.")
        }else if(self.imgData==nil){
            showAlert(msg: "You can't proceed without selecting an image.")
        }
        else
        {
            locHud.show(in: self.view)
            var downloadUrl:URL!
            let storage = Storage.storage()
            let ref = storage.reference().child("tree-images")
            _ = ref.putData(self.imgData, metadata: nil) { (metadata, error) in
                if(error != nil){
                    showAlert(msg: error!.localizedDescription)
                    locHud.dismiss()
                    self.resetFields()
                }else{
                   ref.downloadURL { (url, error) in
                     if(error != nil){
                         showAlert(msg: error!.localizedDescription)
                         locHud.dismiss()
                        self.resetFields()
                     }else if(url != nil){
                        print("URL fetched with success.\n")
                        downloadUrl = url!
                        let ref = Database.database().reference().child("trees-node").childByAutoId()
                        print(downloadUrl)
                        let treeDic:[String:Any]=[
                            "species":species,
                            "height":height as Any,
                            "diameter":diameter as Any,
                            "user-email":self.thisUser.email as Any,
                            "user-id":self.thisUser.userID as Any,
                            "location-lat":self.coord.latitude as Any,
                            "location-lon":self.coord.longitude as Any,
                            "user-given-name":self.thisUser.givenName as Any,
                            "photo-url":downloadUrl.absoluteString
                        ];
                        ref.setValue(treeDic) { (error, ref) -> Void in
                            if(error == nil){
                                showSuccess(msg: "This tree has been uploaded!")
                                locHud.dismiss()
                                self.resetFields()
                            }
                            else{
                                locHud.dismiss()
                                showAlert(msg: error!.localizedDescription)
                                self.resetFields()
                            }
                        }
                     }
                     else{
                        showAlert(msg: "Check your network, you may have issues.")
                    }
                    }
                }
            }
        }
    }
    //MARK:IMAGEPICKER FUNCS
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imgData = pickedImage.pngData()
        }
        dismiss(animated: true, completion: nil)
    }
    func resetFields(){
        self.diameterTextBox.text = ""
        self.heightTxtBox.text = ""
    }
    func setUpSearchBox(){

        let item1 = SearchTextFieldItem(title: "Khejri", subtitle: "Prosopis cineraria")
        let item2 = SearchTextFieldItem(title: "Desert Date", subtitle: "Balanites aegyptiaca")
        let item3 = SearchTextFieldItem(title: "Jujube", subtitle: "Ziziphus jujuba")
        let item4 = SearchTextFieldItem(title:"Castor", subtitle:"Ricinus communis")
        let item5 = SearchTextFieldItem(title:"Sheesham", subtitle:"Tecomella Undulata")
        let item6 = SearchTextFieldItem(title:"Kair", subtitle:"Capparis decidua")
        let item7 = SearchTextFieldItem(title:"Haar Singaar", subtitle:"Nyctanthes arbor-tristis")


        searchTxtBox.filterItems([item1, item2, item3, item4, item5, item6, item7])
        searchTxtBox.theme.font = UIFont.systemFont(ofSize: 18)
        searchTxtBox.theme.bgColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        searchTxtBox.theme.borderColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        searchTxtBox.theme.separatorColor = UIColor (red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        searchTxtBox.theme.cellHeight = 50
    }
}

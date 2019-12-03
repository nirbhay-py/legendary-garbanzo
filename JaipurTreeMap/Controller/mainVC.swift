//
//  mainVC.swift
//  JaipurTreeMap
//
//  Created by Nirbhay Singh on 29/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import ARKit
import SPPermissions
import Firebase
import GoogleSignIn
class mainVC: UIViewController{
    //MARK:IB OUTLETS
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var givenNameLbl: UILabel!
    @IBOutlet weak var picConst: NSLayoutConstraint!
    @IBOutlet weak var nameLblConst: NSLayoutConstraint!
    @IBOutlet weak var treeBtn: UIButton!
    @IBOutlet weak var treeBtnConst: NSLayoutConstraint!
    @IBOutlet weak var logoutBtn: UIButton!
    
    //MARK:GLOBAL VARIABLES
    var thisUser:UserClass!
    
    
    //MARK:VIEWDIDLOAD
    override func viewDidLoad() {
        if(thisUser.email=="na"){
            self.logoutBtn.setTitle("Login", for: .normal)
            enterGuestMode()
            self.givenNameLbl.text = "Guest"
        }
        else{
            populateUserDetails()
        }
        self.profileImgView.layer.cornerRadius = 32
        self.treeBtn.layer.cornerRadius = 20
        self.logoutBtn.layer.cornerRadius = 15
        askPermissions()
        super.viewDidLoad()
    }
    //MARK:VIEWWILLAPPEAR
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    //MARK:VIEWDIDAPPEAR
    //MARK:VIEWWILLDISAPPEAR
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    //MARK:MY FUNCTIONS
    func populateUserDetails(){
        self.givenNameLbl.text = "Hi "+self.thisUser.givenName
        self.profileImgView.load(url: URL(string: thisUser.photoURL)!)
    }
    
    func askPermissions(){
        let isAllowedCamera = SPPermission.isAllowed(.camera)
        let isAllowedLoc = SPPermission.isAllowed(.locationWhenInUse)
        let isAllowedLib = SPPermission.isAllowed(.photoLibrary)
        let boolArray:[Bool]=[isAllowedCamera,isAllowedLoc,isAllowedLib]
        let itemArray:[SPPermissionType]=[SPPermissionType.camera,SPPermissionType.locationAlwaysAndWhenInUse,SPPermissionType.photoLibrary]
        var toAsk:[SPPermissionType]=[]
        for i in 0...2{
            if(boolArray[i]==false){
                toAsk.append(itemArray[i])
            }
        }
        SPPermission.Dialog.request(with: toAsk, on: self)
    }
    
    //MARK:PREPAREFORSEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="addTree"){
            let destVC = segue.destination as! addTreeVC
            destVC.thisUser = self.thisUser
        }
    }
    func enterGuestMode()
    {
        treeBtn.isEnabled = false
        treeBtn.alpha = 0.5
    }
    @IBAction func logout(_ sender: Any) {
       
        if(self.thisUser.email=="na"){
             _ = navigationController?.popToRootViewController(animated: true)
        }
        else{
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut()
            _ = navigationController?.popToRootViewController(animated: true)
        }
        catch{
            showAlert(msg: "Could not sign out.")
            }
        }
    }
}

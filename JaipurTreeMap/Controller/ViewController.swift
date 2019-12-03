//
//  ViewController.swift
//  JaipurTreeMap
//
//  Created by Nirbhay Singh on 29/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import GoogleSignIn
import SCLAlertView
import ARKit
class ViewController: UIViewController, GIDSignInDelegate{
    //MARK:IB OUTLETS
 
    
    //MARK: GLOBAL VARIABLES
    var userToSegue:UserClass!
    let guestUser = UserClass(fullName: "Guest", email: "na", userID: "na", photoURL: "na", givenName: "na")
    
    //MARK: OVERRIDE FUNCTIONS
    
    //MARK:VIEWWILLAPPEAR

    
    //MARK:VIEWDIDAPPEAR
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if(Auth.auth().currentUser != nil){
            let localHud = JGProgressHUD.init()
            localHud.show(in: self.view,animated: true)
            print("called\n")
            //MARK:FETCH DATA FROM FIREBASE, INITIALISE A USERCLASS OBJECT AND PASS IT IN THE SEGUE
            var email = Auth.auth().currentUser?.email
            email = splitString(str: email!, delimiter: ".")
            let ref = Database.database().reference().child("user-node").child(email!)
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                let givenName=value!["givenName"] as! String
                let name = value!["name"] as! String
                let email = value!["email"] as! String
                let photoURL = value!["photoURL"] as! String
                let userID = value!["userID"] as! String
                self.userToSegue = UserClass(fullName: name, email: email, userID: userID, photoURL: photoURL, givenName: givenName)
                localHud.dismiss()
                self.performSegue(withIdentifier: "main", sender: self)
            }){ (error) in
                print(error.localizedDescription)
                showAlert(msg: error.localizedDescription)
            }
        }
    }
    //MARK:VIEWDIDLOAD (DRIVER CODE)
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
    }
    //MARK:VIEWWILLDISAPPEAR

    
    //MARK:GOOGLE SIGN IN FUNCTIONS
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
        if let error = error {
            showAlert(msg: error.localizedDescription)
            return
        }
        let hud = JGProgressHUD.init()
        hud.show(in: self.view,animated: true)
        //MARK:INITIALISING A USER
        let userID = user.userID
        let name = user.profile.name
        let email = user.profile.email
        let givenName = user.profile.givenName
        let photoURL = user.profile.imageURL(withDimension: 150)?.absoluteString
        let userDic = [
              "userID":userID!,
              "givenName":givenName ?? "Empty",
              "name":name!,
              "email":email!,
              "photoURL":photoURL as Any,
              ] as [String : Any]
          let strippedEmail = splitString(str:email!, delimiter:".")
          let ref = Database.database().reference().child("user-node").child(strippedEmail)
          ref.setValue(userDic) { (error, ref) -> Void in
              if(error != nil){
                  hud.dismiss()
                  showAlert(msg: error?.localizedDescription ?? "There seems to be something wrong with your connection.")
              }else{
                  hud.dismiss()
                self.userToSegue = UserClass(fullName: name!, email: email!, userID: userID!, photoURL: photoURL!, givenName: givenName!)
                  showSuccess(msg: "Signed in with success!")
                  self.performSegue(withIdentifier: "main", sender: self)
              }
          }
        }
    }
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier=="main"){
            let destVC = segue.destination as! mainVC
            destVC.thisUser = self.userToSegue
        }
        else if(segue.identifier=="asGuest"){
            let destVC = segue.destination as! mainVC
            destVC.thisUser = self.guestUser
        }
    }
}


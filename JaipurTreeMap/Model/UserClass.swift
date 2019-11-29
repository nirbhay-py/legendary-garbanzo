//
//  UserClass.swift
//  JaipurTreeMap
//
//  Created by Nirbhay Singh on 29/11/19.
//  Copyright © 2019 Nirbhay Singh. All rights reserved.
//

import Foundation

class UserClass{
    var fullName:String!
    var email:String!
    var userID:String!
    var photoURL:String!
    var givenName:String!
    init(fullName:String,email:String,userID:String,photoURL:String!,givenName:String) {
        self.fullName = fullName
        self.email = email
        self.photoURL = photoURL
        self.userID = userID
        self.givenName = givenName
    }
}

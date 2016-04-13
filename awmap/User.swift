//
//  Users.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation

class User {
    var sessionID: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    //logging in and getting user sessionid & Unique key
        
    static let sharedInstance = User()
}
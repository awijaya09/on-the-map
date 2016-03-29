//
//  Student.swift
//  awmap
//
//  Created by Andree Wijaya on 3/29/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation

struct Student {
    
    var firstName: String
    var lastName: String
    var latitude: Float
    var longitude: Float
    var mapString: String
    var mediaURL: String
    var objectId: String
    var uniqueKey: String
    var createdAt: NSString
    var updatedAt: NSString
    
    //constructing student from dictionary
    init(dictionary: [String:AnyObject]){
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Float
        longitude = dictionary["longitude"] as! Float
        mapString = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        objectId = dictionary["objectId"] as! String
        uniqueKey = dictionary["uniqueKey"] as! String
        createdAt = dictionary["createdAt"] as! NSString
        updatedAt = dictionary["updatedAt"] as! NSString
        
    }
    
    static func studentFromResult(results: [[String: AnyObject]]) -> [Student]{
        var students = [Student]()
        
        for result in results {                                                                                                                                                                                                                                                                                                                             
            students.append(Student(dictionary: result))
        }
        
        return students
    }
}
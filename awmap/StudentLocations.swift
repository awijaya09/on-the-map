//
//  StudentLocations.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation

class StudentLocation {
    var objectId: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaUrl: String? = nil
    var latitude: Float? = nil
    var longitude: Float? = nil
    var createdAt: NSDate? = nil
    var updatedAt: NSDate? = nil
    
    
    init(dictionary: [String: AnyObject]){
        objectId = dictionary["objectId"] as? String
        uniqueKey = dictionary["uniqueKey"] as? String
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        mapString = dictionary["mapString"] as? String
        mediaUrl = dictionary["mediaURL"] as? String
        latitude = dictionary["latitude"] as? Float
        longitude = dictionary["longitude"] as? Float
        createdAt = dictionary["createdAt"] as? NSDate
        updatedAt = dictionary["updatedAt"] as? NSDate
        
    }
   
    static func taskForGettingStudentLocations(completionHandlerForGetStudentLocations: (result: [StudentLocation]?, error: NSError?)-> Void){
        
        //1. Set up the parameters
        //2. Build the URL Request
        let url = NSURL(string: Constants.ParseAPI.getStudentLocationRequestURL)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(Constants.ParseAPI.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPI.restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //3. Make the Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else{
                print("Error in getting student locations")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                print("Status code error: \(error)")
                return
            }
            
            guard let data = data else{
                print("Error in getting data")
                return
            }
            
            var parsedResult: AnyObject!
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch{
                print("Error in getting parsed data")
                return
            }
            
            guard let resultDictionary = parsedResult["results"] as? [String: AnyObject] else{
                print("Error in getting results array")
                return
            }
            
            //print(resultDictionary)
            //completionHandlerForGetStudentLocations(result: resultDictionary, error: <#T##NSError?#>)
            
    
            
            
        }
        
        //4. Parse the data
        //5. Use the data
        //6. Start the request
        task.resume()
        
    }
    
}
//
//  Student.swift
//  awmap
//
//  Created by Andree Wijaya on 3/29/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation

struct Student{
    
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
    
    static func getStudentList(completionHandlerForStudentList: (result: [Student]?, error: NSError?)-> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(Constants.ParseAPI.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPI.restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandlerForStudentList(result: nil, error: error)
                return
            }
            
            guard let data = data else{
                completionHandlerForStudentList(result: nil, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                completionHandlerForStudentList(result: nil, error: error)
                return
            }
            
            var parsedResult: AnyObject
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch{
                return
            }
            
            guard let resultArray = parsedResult["results"] as? [[String: AnyObject]] else{
                completionHandlerForStudentList(result: nil, error: error)
                return
            }
            
            let students = self.studentFromResult(resultArray)
            completionHandlerForStudentList(result: students, error: nil)
        }
        task.resume()
    }

}
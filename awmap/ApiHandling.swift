//
//  ApiHandling.swift
//  awmap
//
//  Created by Andree Wijaya on 4/13/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import Foundation
import MapKit


class ApiHandling{
    
    static let sharedInstance = ApiHandling()
    private init(){}
    var studentList = [Student]()
    
    func getStudentList(completionHandlerForStudentList: (result: [Student]?, error: NSError?)-> Void){
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
            
            let students = Student.studentFromResult(resultArray)
            completionHandlerForStudentList(result: students, error: nil)
        }
        task.resume()
    }
    
    func getSessionID(username: String, password: String, completionHandlerForLogin: (success: Bool, error: NSError?)-> Void ) {
        
        
        let components = NSURLComponents()
        components.scheme = Constants.UdacityAPI.apiScheme
        components.host = Constants.UdacityAPI.apiHost
        components.path = Constants.UdacityAPI.apiPath
        
        print(components.URL!)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("udacity\": {\"username\": \(username), \"password\": \(password)}")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            
            guard (error == nil) else{
                completionHandlerForLogin(success: false, error: error)
                return
            }
            
            guard let data = data else{
                completionHandlerForLogin(success: false, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                completionHandlerForLogin(success: false, error: error)
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsedResult: AnyObject!
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            }catch{
                print("Parsing data error")
                return
            }
            guard let account = parsedResult["account"] as? [String: AnyObject] else {
                completionHandlerForLogin(success: true, error: error)
                return
            }
            
            guard let registered = account["registered"] as? Bool where registered == true else{
                completionHandlerForLogin(success: false, error:error)
                return
            }
            
            guard let uniqueKey = account["key"] as? String else{
                completionHandlerForLogin(success: false, error: error)
                return
            }
            
            guard let sessionDict = parsedResult["session"] as? [String: AnyObject] else{
                completionHandlerForLogin(success: false, error: error)
                return
            }
            
            guard let sessionID = sessionDict["id"] as? String else {
                completionHandlerForLogin(success: false, error: error)
                return
            }
            
            
            print(sessionID)
            print(uniqueKey)
            User.sharedInstance.sessionID = sessionID
            User.sharedInstance.uniqueKey = uniqueKey
            completionHandlerForLogin(success: true, error: nil)
            
        }
        task.resume()
        
    }
    
    //logging out and deleting sessionID
    func logoutSession(completionHandlerForLogout: (success: Bool, error: NSError?)-> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil) else{
                completionHandlerForLogout(success: false, error: error)
                return
            }
            
            guard let data = data else{
                completionHandlerForLogout(success: false, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                completionHandlerForLogout(success: false, error: error)
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            completionHandlerForLogout(success: true, error: nil)
        }
        task.resume()
    }
    
    func getUserData(uniqueKey: String , completionHandlerForUserData: (success: Bool, error: NSError?)-> Void){
        let url = NSURL(string: "https://www.udacity.com/api/users/\(uniqueKey)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil) else{
                completionHandlerForUserData(success: false, error: error)
                return
            }
            
            guard let data = data else{
                completionHandlerForUserData(success: false, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                completionHandlerForUserData(success: false, error: error)
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedResult: AnyObject!
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            }catch{
                print("Error in getting user data: \(error)")
            }
            
            guard let user = parsedResult["user"] as? [String: AnyObject] else{
                completionHandlerForUserData(success: false, error: error)
                return
            }
            
            guard let lastName = user["last_name"] as? String else{
                completionHandlerForUserData(success: false, error: error)
                return
            }
            
            guard let firstName = user["nickname"] as? String else{
                completionHandlerForUserData(success: false, error: error)
                return
            }
            
            User.sharedInstance.firstName = firstName
            User.sharedInstance.lastName = lastName
            
            
            
        }
        task.resume()
    }
    
    func postLocation(mapString: String, mediaUrl: String,pointAnnotation: MKAnnotation, completionHandlerForPostLocation: (success: Bool, error: NSError?)-> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseAPI.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPI.restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(User.sharedInstance.uniqueKey!)\", \"firstName\": \"\(User.sharedInstance.firstName!)\", \"lastName\": \"\(User.sharedInstance.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(pointAnnotation.coordinate.latitude), \"longitude\": \(pointAnnotation.coordinate.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil) else{
                completionHandlerForPostLocation(success: false, error: error)
                return
            }
            guard let data = data else{
                completionHandlerForPostLocation(success: false, error: error)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                completionHandlerForPostLocation(success: false, error: error)
                return
            }
            
            var parsedResult: AnyObject
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }catch{
                return
            }
            print(parsedResult)
            completionHandlerForPostLocation(success: true, error: nil)
        }
        task.resume()

    }

}
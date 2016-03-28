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
    
    func getSessionID(username: String, password: String, completionHandlerForLogin: (success: Bool, error: String?)-> Void ) {
        
        
        let components = NSURLComponents()
        components.scheme = Constants.UdacityAPI.APIScheme
        components.host = Constants.UdacityAPI.APIHost
        components.path = Constants.UdacityAPI.APIPath
        
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
                completionHandlerForLogin(success: false, error: "\(error)")
                return
            }
            
            guard let data = data else{
                completionHandlerForLogin(success: false, error: "No data response")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else{
                completionHandlerForLogin(success: false, error: "Error in status code \(error)")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            var parsedResult: AnyObject!
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            }catch{
                completionHandlerForLogin(success: false, error: "Failure in getting the result \(error)" )
                return
            }
            guard let account = parsedResult["account"] as? [String: AnyObject] else {
                completionHandlerForLogin(success: true, error: "Failed to get account details")
                return
            }
            
            guard let registered = account["registered"] as? Bool where registered == true else{
                completionHandlerForLogin(success: false, error:"Username not registered")
                return
            }
            
            guard let sessionDict = parsedResult["session"] as? [String: AnyObject] else{
                completionHandlerForLogin(success: false, error: "failed to get session dictionary")
                return
            }
            
            guard let sessionID = sessionDict["id"] as? String else {
                completionHandlerForLogin(success: false, error: "Failed to get session ID")
                return
            }
            
            
            print(sessionID)
            
            self.sessionID = sessionID
            completionHandlerForLogin(success: true, error: nil)
            
        }
        task.resume()
        
    }
    
    
    class func sharedInstance() -> User {
        struct Singleton {
            static var sharedInstance = User()
        }
        return Singleton.sharedInstance
    }
}
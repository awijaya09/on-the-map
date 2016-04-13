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
            self.sessionID = sessionID
            self.uniqueKey = uniqueKey
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
    
    class func sharedInstance() -> User {
        struct Singleton {
            static var sharedInstance = User()
        }
        return Singleton.sharedInstance
    }
}
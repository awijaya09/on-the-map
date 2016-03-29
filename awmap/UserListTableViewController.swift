//
//  UserListTableViewController.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit

class UserListTableViewController: UITableViewController {
    let cellIdentifier = "studentCell"
    @IBOutlet var studentListTableView: UITableView!
    
    
    var studentList1 = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getStudentList { (result, error) in
            guard (result != nil || error == nil) else {
                print("Unable to get student list")
                return
            }
            
            self.studentList1 = result!
            performUpdateOnMain({ 
                self.studentListTableView.reloadData()
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentList1.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let student = studentList1[indexPath.row]
        
        cell.textLabel?.text = student.firstName
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let mediaURL = tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text else{
            let alertController = UIAlertController(title: "Invalid", message: "Invalid Link", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(action)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if let referenceURL = NSURL(string: mediaURL){
            UIApplication.sharedApplication().openURL(referenceURL)
        }

    }
    
    func getStudentList(completionHandlerForStudentList: (result: [Student]?, error: NSError?)-> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
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


}

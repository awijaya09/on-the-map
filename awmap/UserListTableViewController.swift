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
    
    let studentList = [["firstName": "Jarrod", "lastName": "Parkes", "objectID": "JhOtcRkxsh", "latitude": 34.7303688, "longitude": -86.5861037, "mediaURL": "https://www.linkedin.com/in/jarrodparkes"],
                       ["firstName": "Jessica", "lastName": "Uelmen", "objectID": "kj18GEaWD8", "latitude": 28.1461248, "longitude": -82.756768, "mediaURL": "www.linkedin.com/in/jessicauelmen/en"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
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
        return studentList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        var studentName = ""
        let student = studentList[indexPath.row] as NSDictionary
        if let firstName = student["firstName"] as? String {
            if let lastName = student["lastName"] as? String {
                studentName = firstName + " " + lastName
                cell.textLabel?.text = studentName
            }
        }
        if let mediaURL = student["mediaURL"] as? String {
            print(mediaURL)
            cell.detailTextLabel?.text = mediaURL
            
        }else {
            "unable to find mediaURL"
        }
        
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


}

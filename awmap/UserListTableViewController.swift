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
    
    
    func getStudentList(){
        ApiHandling.sharedInstance.getStudentList { (result, error) in
            guard (result != nil || error == nil) else {
                print("Unable to get student list")
                return
            }
            print("Have gotten student List Data")
            ApiHandling.sharedInstance.studentList = result!
            
            performUpdateOnMain({
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func logoutSession(sender: AnyObject) {
        ApiHandling.sharedInstance.logoutSession { (success, error) in
            guard (success || error == nil) else{
                print("logout failed")
                return
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    @IBAction func reloadStudentList(sender: AnyObject) {
        getStudentList()
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ApiHandling.sharedInstance.studentList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let student =  ApiHandling.sharedInstance.studentList[indexPath.row]
        
        cell.textLabel?.text = student.firstName + " " + student.lastName
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
            if (UIApplication.sharedApplication().canOpenURL(referenceURL)){
                UIApplication.sharedApplication().openURL(referenceURL)
            }else{
                performUpdateOnMain({
                    let alert = UIAlertController(title: "Oops!", message: "Unable to open media url", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }

    }
    
    

}

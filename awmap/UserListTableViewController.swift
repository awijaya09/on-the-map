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
     override func viewDidLoad() {
        super.viewDidLoad()
 
        }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
        return ((UIApplication.sharedApplication().delegate as? AppDelegate)?.studentList.count)!
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let student = (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentList[indexPath.row]
        
        cell.textLabel?.text = student!.firstName
        cell.detailTextLabel?.text = student!.mediaURL
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

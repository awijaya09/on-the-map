//
//  MainMapViewController.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit
import MapKit


class MainMapViewController: UIViewController {
    
    @IBOutlet weak var darkenImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        darkenImageView.hidden = false
        Student.getStudentList { (result, error) in
            guard (result != nil || error == nil) else {
                print("Unable to get student list")
                return
            }
            print("Have gotten student List Data")
            (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentList = result!
            
            performUpdateOnMain({
                self.darkenImageView.hidden = true
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    
}

//
//  LocationDetailViewController.swift
//  awmap
//
//  Created by Andree Wijaya on 4/2/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


extension LocationDetailViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    
    func resignIfFirstResponder(textfield: UITextField) {
        if textfield.isFirstResponder() {
            textfield.resignFirstResponder()
        }
    }
    
    @IBAction func userTapView(sender: AnyObject){
       resignIfFirstResponder(locationTextField)
    }

}
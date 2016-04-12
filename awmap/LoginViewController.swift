//
//  ViewController.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var keyboardPresent = false
    var enabled = false
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //notification for keyboard show and hide
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(LoginViewController.keyboardWillShow(_:)))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(LoginViewController.keyboardWillHide(_:)))
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    
        
        
        //adjusting the activity indicator
        
        let usernameTextFieldPaddingView = UIView(frame: CGRectMake(0, 0, 15, self.usernameTextField.frame.height))
        usernameTextField.leftView = usernameTextFieldPaddingView
        usernameTextField.leftViewMode = UITextFieldViewMode.Always
        
        let passwordTextFieldPaddingView = UIView(frame: CGRectMake(0, 0, 15, self.passwordTextField.frame.height))
        passwordTextField.leftView = passwordTextFieldPaddingView
        passwordTextField.leftViewMode = UITextFieldViewMode.Always
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        errorLabel.hidden = true
    
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotification()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginPressed(sender: UIButton) {
        if(!enabled){
            activityIndicator.startAnimating()
            enableTextField(usernameTextField)
            enableTextField(passwordTextField)
            loginButton.enabled = enabled
            enabled = !enabled
        }
        
        User.sharedInstance().getSessionID(usernameTextField.text!, password: passwordTextField.text!) { (success, error) -> Void in
            if success {
                print("managed to get session ID")
                performUpdateOnMain({ 
                    self.errorLabel.text = "Login Successful!"
                })
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigationController") as! UITabBarController
                self.presentViewController(controller, animated: true, completion: nil)
            }else{
              
                performUpdateOnMain({
                    self.enableTextField(self.usernameTextField)
                    self.enableTextField(self.passwordTextField)
                    self.loginButton.enabled = self.enabled
                    self.enabled = !self.enabled
                    let alert = UIAlertController(title: "Login Failed", message: "Invalid username/password", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(action)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    self.activityIndicator.stopAnimating()
                })
                  print("Failed, do better please! \(error)")
            }
        }
    }
    
    @IBAction func signUpPressed(sender: UIButton) {
        if let signupUrl = NSURL(string: "https://www.udacity.com/account/auth#!/signup"){
            UIApplication.sharedApplication().openURL(signupUrl)
        }
        
        
    }
    
    

}

extension LoginViewController {
    func subscribeToNotification(notification: String, selector: Selector){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotification(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func enableTextField(textField: UITextField){
        textField.enabled = enabled
    }
  }

extension LoginViewController: UITextFieldDelegate{
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

    func keyboardWillShow(notification: NSNotification) {
        if (passwordTextField.isFirstResponder()){
            self.view.frame.origin.y = (getKeyboardHeight(notification)/2) * -1
            print(getKeyboardHeight(notification))
        }else if usernameTextField.isFirstResponder(){
            self.view.frame.origin.y = -50.0
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (passwordTextField.isFirstResponder()){
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.CGRectValue().height
       
    }
    
    func resignIfFirstResponder(textfield: UITextField) {
        if textfield.isFirstResponder() {
            textfield.resignFirstResponder()
        }
    }
    
    @IBAction func userTapView(sender: AnyObject){
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
}


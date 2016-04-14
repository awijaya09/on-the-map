//
//  ViewController.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    var keyboardPresent = false
    var enabled = false
    let facebookReadPermission = ["public_profile", "email"]
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginWithFacebook: UIButton!
    
    
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
       
        //Facebook Login        
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.stopAnimating()
        usernameTextField.text = ""
        passwordTextField.text = ""
        enabled = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotification()
    }
    //custom facebook login button
    @IBAction func facebookLoginButtonPressed(sender: AnyObject){
        activityIndicator.startAnimating()
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (result, error) in
            guard (error == nil) else{
                print("error in custom facebook login")
                return
            }
            let fbLoginResult : FBSDKLoginManagerLoginResult = result
            if(fbLoginResult.grantedPermissions.contains("email")){
                print(fbLoginResult.token.tokenString)
                FBSDKAccessToken.setCurrentAccessToken(fbLoginResult.token)
                ApiHandling.sharedInstance.loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString) { (success, error) in
                    guard (error == nil && success == true) else{
                        performUpdateOnMain({
                            let alert = UIAlertController(title: "Error", message: "Couldn't login with Facebook", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                        
                        return
                    }
                    
                    performUpdateOnMain({
                        print("It goes here")
                        self.activityIndicator.stopAnimating()
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MainNavigationController") as! UITabBarController
                        self.presentViewController(controller, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
       @IBAction func loginPressed(sender: UIButton) {
        if(!enabled){
            activityIndicator.startAnimating()
            enableTextField(usernameTextField)
            enableTextField(passwordTextField)
            loginButton.enabled = enabled
            enabled = !enabled
        }
        
        ApiHandling.sharedInstance.getSessionID(usernameTextField.text!, password: passwordTextField.text!) { (success, error) -> Void in
          
            guard (error?.code != -1009) else{
                print("this guard is invoked")
                performUpdateOnMain({ 
                    let alert = UIAlertController(title: "Network Error", message: "Error in network connection", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(action)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.enableTextField(self.usernameTextField)
                    self.enableTextField(self.passwordTextField)
                    self.loginButton.enabled = self.enabled
                    self.enabled = !self.enabled

                    self.activityIndicator.stopAnimating()
                })
                
                return
            }
            if success {
                print("managed to get session ID")
                self.activityIndicator.stopAnimating()
                self.enableTextField(self.usernameTextField)
                self.enableTextField(self.passwordTextField)
                self.loginButton.enabled = self.enabled
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
//        if (passwordTextField.isFirstResponder()){
            var viewRect = self.view.frame
            viewRect.size.height -= getKeyboardHeight(notification)
            if(!CGRectContainsPoint(viewRect, loginButton.frame.origin)){
                self.view.frame.origin.y = (getKeyboardHeight(notification)/2) * -1
            }
            else{
                print("If statement not triggered")
            }
         
           //}
    }
    
    func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 0
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


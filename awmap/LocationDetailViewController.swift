//
//  LocationDetailViewController.swift
//  awmap
//
//  Created by Andree Wijaya on 4/2/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailViewController: UIViewController, MKMapViewDelegate {

    var mapString :String!
    var mediaUrl: String!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var postMyLocation: UIButton!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    @IBOutlet weak var whereAreYouLabel: UILabel!
    
    @IBOutlet weak var middleImageView: UIImageView!
    
    var annotation: MKAnnotation!
    var localSearchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearchResponse!
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    
    
     override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
        linkTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        linkTextField.hidden = true
        mapView.hidden = true
        postMyLocation.enabled = false
        postMyLocation.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postLocation(sender: UIButton) {
        mediaUrl = linkTextField.text
        ApiHandling.sharedInstance.postLocation(mapString, mediaUrl: mediaUrl, pointAnnotation: pointAnnotation) { (success, error) in
            guard(error == nil) else{
                let alertController = UIAlertController(title: "Warning", message: "Unable to post location", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return
            }
            
            if success{
                 self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
       
        
    }
    @IBAction func findLocationOnTheMap(sender: UIButton) {
        performUpdateOnMain { 
            self.activityIndicator.startAnimating()
            
        }
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationTextField.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) in
            guard (error == nil) else{
                performUpdateOnMain({ 
                    let alertController = UIAlertController(title: "Warning", message: "Place not found", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(action)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                })
                return
            }
            
            guard (localSearchResponse != nil) else{
                let alertController = UIAlertController(title: "Warning", message: "Place not found", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.locationTextField.text
            self.mapString = self.locationTextField.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2DMake(localSearchResponse!.boundingRegion.center.latitude, localSearchResponse!.boundingRegion.center.longitude)
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            self.mapView.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 5000, 5000)
            
            performUpdateOnMain({ 
                self.mapView.hidden = false
                self.linkTextField.hidden = false
                self.postMyLocation.hidden = false
                self.postMyLocation.enabled = true
                self.locationTextField.hidden = true
                self.whereAreYouLabel.hidden = true
                self.findOnTheMapButton.enabled = false
                self.findOnTheMapButton.hidden = true
                self.activityIndicator.stopAnimating()
            })
            
        }
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
        resignIfFirstResponder(linkTextField)
    }

}
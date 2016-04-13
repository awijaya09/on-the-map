//
//  MainMapViewController.swift
//  awmap
//
//  Created by Andree Wijaya on 3/28/16.
//  Copyright © 2016 Andree Wijaya. All rights reserved.
//

import UIKit
import MapKit


class MainMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var darkenImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainMap: MKMapView!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMap.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getStudentList()
    }
    
    func getStudentList(){
        activityIndicator.startAnimating()
        darkenImageView.hidden = false
        Student.getStudentList { (result, error) in
            guard (error == nil) else {
                print("Unable to get student list")
                return
            }
            
            guard(result != nil) else{
                performUpdateOnMain({ 
                    let alert = UIAlertController(title: "Warning", message: "Unable to get Student List", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alert.addAction(action)
                    self.darkenImageView.hidden = true
                    self.activityIndicator.stopAnimating()
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }
            
            print("Have gotten student List Data")
            (UIApplication.sharedApplication().delegate as? AppDelegate)?.studentList = result!
            
            performUpdateOnMain({
                self.darkenImageView.hidden = true
                self.activityIndicator.stopAnimating()
                self.mainMap.addAnnotations(self.getMapAnnotations())
            })
        }
    }
 
    @IBAction func logoutUser(sender: AnyObject) {
        activityIndicator.startAnimating()
        darkenImageView.hidden = false
        User.sharedInstance().logoutSession { (success, error) in
            guard (success || error == nil) else{
                print("logout failed")
                return
            }
            self.activityIndicator.stopAnimating()
            self.darkenImageView.hidden = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    @IBAction func refreshList(sender: AnyObject) {
        getStudentList()
    }
    
    func getMapAnnotations() -> [MKPointAnnotation]{
        var location: CLLocationCoordinate2D
        var annotations = [MKPointAnnotation]()
        for student in (UIApplication.sharedApplication().delegate as! AppDelegate).studentList {
            let latitude = Double(student.latitude)
            let longitude = Double(student.longitude)
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = student.firstName + " " + student.lastName
            annotation.subtitle = student.mediaURL
            annotations.append(annotation)
        }
        return annotations
    }
    
    //similar to cellForRowAtIndexPath
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "studentPin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView{
            dequeuedView.annotation = annotation
            view = dequeuedView
        }else{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        return view
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let studentUrl = view.annotation?.subtitle{
            if (UIApplication.sharedApplication().canOpenURL(NSURL(string: studentUrl!)!)){
                UIApplication.sharedApplication().openURL(NSURL(string: studentUrl!)!)
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

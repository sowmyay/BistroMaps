//
//  BaseController.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/13/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import SystemConfiguration

class BaseController: UIViewController, LocationManagerDelegate{
    
    var managedContext:NSManagedObjectContext?
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        LM.instance.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeTouch(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backTouch(_ sender: Any?) {
        _ = self.navigationController?.popViewController(animated:true)
    }
    
    func addLoaderView() {
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func showLoadingIndicator(){
        indicator.bringSubview(toFront: view)
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func hideLoadingIndicator(){
        indicator.isHidden = true
        indicator.stopAnimating()
    }
    
    //MARK: LocationManagerDelegate Methods
    func locationDidUpdate(_ location: CLLocation) {
        print(location)
        print("came here in base")
        //LM.getLocationAddress(location) { (address) in }
        LM.instance.endUpdatingLocation()
    }
    
    func didChangeAuthorizationStatus(_ status:CLAuthorizationStatus) {
    }
    
    //MARK:- CALocationDelegate Methods
    //--------------------------
    
    func startUpdatingLocation(){
        if !CLLocationManager.locationServicesEnabled(){
            openLocationSettingAlert(title: "Location Service Not Available", msg:"Please enable your location!")
            //UI
        }else if CLLocationManager.authorizationStatus() != .authorizedWhenInUse{
            
            openLocationSettingAlert(title: "Location Permission Denied", msg:"Please provide location permission to ResQ!")
            
        }else{
            LM.instance.locationManager.startUpdatingLocation()
            //            self.showLoadingIndicator()
        }
    }
    
    private func openLocationSettingAlert(title: String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (result) in
            print("Cancel")
        }
        let enableAction = UIAlertAction(title: "Enable", style: .default) { (result) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(dismissAction)
        alert.addAction(enableAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
}

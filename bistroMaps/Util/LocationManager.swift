//
//  LocationManager.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/14/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit
import CoreLocation

typealias LM = LocationManager

protocol LocationManagerDelegate:class {
    
    func locationDidUpdate(_ location:CLLocation)
    func didChangeAuthorizationStatus(_ status:CLAuthorizationStatus)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let instance = LocationManager()
    var locationManager:CLLocationManager!
    var currentLocation:CLLocation? {
        return locationManager.location
    }
    weak var delegate:LocationManagerDelegate?

    private override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        ///This indicates to the location service that 10 meter minimum movement filter is desired.
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    //MARK: CLLocationManagerDelegate Methods
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.delegate?.locationDidUpdate(locations.last!)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.delegate?.didChangeAuthorizationStatus(status)
    }
    
    public class func locationServicesEnabled() -> Bool {
        guard CLLocationManager.locationServicesEnabled(),
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
                return false
        }
        return true
    }
    
    public func endUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
}

//
//  BistroDirectionsController.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/15/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON
import MapKit

class BistroDirectionsController: BaseController , GMSMapViewDelegate{

    @IBOutlet weak var mapView: GMSMapView!
    let regionRadius: CLLocationDistance = 3000
    var currentLocation = CLLocation(latitude: 33.77, longitude: -84.41)
    var destLocation = CLLocation(latitude: 33.77, longitude: -87.41)
    var destDetails:Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15.0)
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView.isTrafficEnabled = true
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.zoomGestures = true
        
        drawPath(startLocation: currentLocation, endLocation: destLocation)
        if let title = destDetails?.title, let icon = destDetails?.icon{
            createMarker(titleMarker: title, iconMarker: icon, latitude: destLocation.coordinate.latitude, longitude: destLocation.coordinate.longitude)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.clear()
        drawPath(startLocation: currentLocation, endLocation: destLocation)
        if let title = destDetails?.title, let icon = destDetails?.icon{
            createMarker(titleMarker: title, iconMarker: icon, latitude: destLocation.coordinate.latitude, longitude: destLocation.coordinate.longitude)
        }
    }
    
    @IBAction func openMaps(_ sender: Any) {
        // if GoogleMap installed
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(Float(destLocation.coordinate.latitude)),\(Float(destLocation.coordinate.longitude))&directionsmode=driving")! as URL)
            
        } else {
            // if GoogleMap App is not installed
            UIApplication.shared.openURL(NSURL(string:
                "https://maps.google.com/?q=@\(Float(destLocation.coordinate.latitude)),\(Float(destLocation.coordinate.longitude))")! as URL)
        }
    }
    
    // MARK: function for create a marker pin on map
    func createMarker(titleMarker: String, iconMarker: String?, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        
        marker.map = mapView
        marker.icon = UIImage(named: "location")
        if let icon = iconMarker{
            Alamofire.request(icon, method: .get).responseImage { response in
                if let data = response.result.value {
                    //                        let image = UIImage(data: data)
                    marker.icon = data
                }
            }
        }
    }
    
    // MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        mapView.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }
    
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            
            let json = try! JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.blue
                polyline.map = self.mapView
            }
            
        }
    }
    
    //MARK:- LocationManagerDelegate Methods
    override func locationDidUpdate(_ location: CLLocation) {
        super.locationDidUpdate(location)
        currentLocation = location

        drawPath(startLocation: currentLocation, endLocation: destLocation)
        
        LM.instance.locationManager.stopUpdatingLocation()
    }


}

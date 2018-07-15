//
//  BistroMapController.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/13/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import AlamofireImage
import GooglePlaces
import GoogleMaps
import SwiftyJSON

class BistroMapController: BaseController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var txtField: PaddingTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentLocation = CLLocation(latitude: 33.77, longitude: -84.41)
    var regionRadius: Int = 3000
    var locationsList = [Location]()
    var markerList = [GMSMarker]()
    var polyline:GMSPolyline = GMSPolyline()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        //Your map initiation code
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15.0)
        
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.compassButton = true
        self.mapView.settings.zoomGestures = true
        startUpdatingLocation()
        txtField.delegate = self
        txtField.addDoneCancelToolbar()
    }
    
    //MARK:- LocationManagerDelegate Methods
    override func locationDidUpdate(_ location: CLLocation) {
        super.locationDidUpdate(location)
        currentLocation = location
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15.0)
        self.mapView.camera = camera
        LM.instance.locationManager.stopUpdatingLocation()
        
        placeCall(lat: Float(currentLocation.coordinate.latitude), lng: Float(currentLocation.coordinate.longitude))
    }

    
    func placeCall(lat:Float, lng:Float, radius:Int = 1500, type:String = "restaurant"){
        showLoadingIndicator()
        
        let placesReq = PlacesRequest(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, radius: radius, type: type)
        RequestSender().sendRequest(placesReq, success: { (response) in
            self.hideLoadingIndicator()
            let placesResponse = response as! PlacesResponse
            self.locationsList = placesResponse.locations
            self.addMapLocations(list: self.locationsList)
            self.collectionView.reloadData()
        }) { (error) in
            self.hideLoadingIndicator()
            print(error)
        }
    }
    
}
extension BistroMapController:GMSMapViewDelegate{
    func addMapLocations(list: [Location] = [Location]()){
        mapView.clear()
        markerList = []
        for loc in list{
            markerList += [createMarker(loc: loc)]
        }
    }
    
    func createMarker(loc:Location) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = loc.title
        marker.snippet = loc.locationName
        marker.map = mapView
        marker.icon = UIImage(named: "location")
        if let icon = loc.icon{
            Alamofire.request(icon, method: .get).responseImage { response in
                if let data = response.result.value {
                    //                        let image = UIImage(data: data)
                    marker.icon = data
                }
            }
        }
        return marker
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
        if let index = markerList.index(of: marker){
            
            let firstIndex = IndexPath(item: index, section: 0)
            collectionView.scrollToItem(at: firstIndex, at: .centeredHorizontally, animated: true)
            selectMarker(loc: locationsList[index], firstItem: firstIndex)
        }
        
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
}

extension BistroMapController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationsList.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationDetailsCell", for: indexPath) as! LocationDetailsCell
        cell.config(loc: locationsList[indexPath.row], initialLocation: currentLocation)
        cell.delegate = self
        return cell
    }
    
    func selectMarker(loc:Location, firstItem:IndexPath){
        self.polyline.map = nil
        let destLocation = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        
        drawPath(startLocation: currentLocation, endLocation: destLocation)
        
        let selected = markerList[firstItem.item]
        mapView.selectedMarker = selected
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let list = collectionView.indexPathsForVisibleItems
        let firstItem = list[0]
        let loc = locationsList[firstItem.row]
        selectMarker(loc: loc, firstItem: firstItem)
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
                self.polyline = GMSPolyline.init(path: path)
                self.polyline.strokeWidth = 4
                self.polyline.strokeColor = UIColor.blue
                self.polyline.map = self.mapView
            }
            
        }
    }
    
}

extension BistroMapController:LocationDetailsCellDelegate{
    
    func directionsTouch(_ location: CLLocation, details:Location?) {
        let vc = self.tabBarController?.viewControllers![1] as? BistroDirectionsController
        vc?.currentLocation = currentLocation
        vc?.destLocation = location
        vc?.destDetails = details
        self.tabBarController?.selectedIndex = 1
    }
}

extension BistroMapController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.regionRadius=Int(textField.text!)!
        placeCall(lat: Float(currentLocation.coordinate.latitude), lng: Float(currentLocation.coordinate.longitude), radius:self.regionRadius)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
        
    }
}


//
//  PlacesResponse.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/15/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit
import MapKit

class PlacesResponse: BaseResponse {

    var locations = [Location]()
    
    init(response:NSDictionary) {
        if let locs = response["results"] as? NSArray{
            for item in locs{
                let loc = Location(data: item as! NSDictionary, type: "hospitals")
                locations.append(loc)
            }
        }
    }
}

class Location: NSObject, MKAnnotation{
    let title: String?
    let locationName: String?
    let pricingLevel:Int?
    let coordinate: CLLocationCoordinate2D
    var rating:Double?
    var imgString:String? = nil
    var icon:String?
    
    init(data:NSDictionary, type:String) {
        let geometry = data["geometry"] as! NSDictionary
        let loc = geometry["location"] as! NSDictionary
        let lat = loc["lat"] as! Double
        let lng = loc["lng"] as! Double
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        self.title = data["name"] as? String
        self.locationName = data["vicinity"] as? String
        self.pricingLevel = data["price_level"] as? Int
        
        if let photos = data["photos"] as? NSArray{
            let photoDict = photos[0] as! NSDictionary
            imgString = photoDict["photo_reference"] as? String
        }
        icon = data["icon"] as? String
        rating = data["rating"] as? Double
//        self.phone = data["phone"] as? String
    }
    var subtitle: String? {
        return locationName
    }
}

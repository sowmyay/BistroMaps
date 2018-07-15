//
//  PlacesRequest.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/15/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit

class PlacesRequest: BaseRequest {
    
    var latitude: Double?
    var longitude: Double?
    var radius:Int?
    var type:String?
    var apikey:String = Singleton.instance.apiKey
    
    init(lat:Double?, lon:Double?, radius:Int?, type:String?){
        self.latitude = lat
        self.longitude = lon
        self.radius = radius
        self.type = type
    }
    

}

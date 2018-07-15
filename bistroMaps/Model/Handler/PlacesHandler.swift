//
//  PlacesHandler.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/15/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit

class PlacesHandler: BaseHandler {

    override func getHTTPMethod(_ request:BaseRequest) -> String {
        return "GET"
    }
    
    override func getURL(_ request:BaseRequest) -> String {
        
        return super.getURL(request)
    }
    
    override func constructDictionary(_ request:BaseRequest) -> [String : AnyObject] {
        super.constructDictionary(request)
        let placesReq = request as! PlacesRequest
        dictionary["location"] = String(format:"%f", placesReq.latitude!)+","+String(format:"%f", placesReq.longitude!) as AnyObject
        dictionary["radius"] = placesReq.radius as AnyObject
        dictionary["type"] = placesReq.type as AnyObject
        dictionary["key"] = placesReq.apikey as AnyObject
        return dictionary
    }
    
    override func parser(_ response: AnyObject) -> BaseResponse? {
        
        let data = response as! NSDictionary
        return PlacesResponse(response: data)
    }
}

//
//  BaseHandler.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/13/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit

class BaseHandler: NSObject {

    var dictionary = [String:AnyObject]()
    
    required override init() {
        super.init()
        
        print("\(self) - Handler Initialised")
    }
    
    func getHTTPMethod(_ request:BaseRequest) -> String {
        return "GET"
    }
    
    func getURL(_ request:BaseRequest) -> String {
        return  C.URL.placesAPI
        
    }
    
    @discardableResult
    func constructDictionary(_ request:BaseRequest) -> [String:AnyObject] {
        return dictionary
    }
    
    func parser(_ response: AnyObject) -> BaseResponse? {
        return nil
    }
    
    deinit {
        print("\(self) - Handler Released")
    }
}

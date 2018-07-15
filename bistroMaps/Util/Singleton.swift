//
//  Singleton.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/13/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import Foundation

class Singleton: NSObject {
    static let instance = Singleton()
    
    ///This makes sure that we can't get an instance variable of Singlton.
    private override init() {
        super.init()
    }
    
    var apiKey:String = "AIzaSyDo_3idxghL81J9bOFvkX1391uAYoCzTrY"

}

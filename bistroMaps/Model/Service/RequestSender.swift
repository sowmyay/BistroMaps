//
//  RequestSender.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/15/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit

class RequestSender{
    
    let requestList:[BaseRequest.Type] = [PlacesRequest.self]
    let handlerList:[BaseHandler.Type] = [PlacesHandler.self]
    
    func sendRequest(_ request:BaseRequest, success:@escaping (_ response:BaseResponse)->Void, failure:@escaping (_ error:Any)->Void) {
        
        let handlerType:BaseHandler.Type = self.getHandler(request)
        
        let handlerClass    = handlerType.init()
        let url             = handlerClass.getURL(request)
        let dict            = handlerClass.constructDictionary(request)
        let httpMethod      = handlerClass.getHTTPMethod(request)
        
        HTTPServiceProvider.sharedInstance.submitJSON(dict, url: url, httpMethod: httpMethod, success: { (response) in
            let responseObject = handlerClass.parser(response)
            success(responseObject!)
        }){ (error) in
            failure(error)
        }
    }
    
    func getHandler(_ request:BaseRequest) -> BaseHandler.Type {
        var index = 0
        for item in requestList {
            if (item === type(of: request)) {break}
            else {index += 1}
        }
        return handlerList[index]
    }
}


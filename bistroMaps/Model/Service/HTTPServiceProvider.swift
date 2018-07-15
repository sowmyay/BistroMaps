//
//  HTTPServiceProvider.swift
//  bistroMaps
//
//  Created by sowmya yellapragada on 7/15/18.
//  Copyright © 2018 sowmya.yellapragada. All rights reserved.
//

import UIKit
import Alamofire

class HTTPServiceProvider{
    
    static let sharedInstance = HTTPServiceProvider()
    
    func submitJSON(_ json:[String : AnyObject], url:String, httpMethod:String, success:@escaping (_ response:AnyObject)->Void, failure:@escaping (_ error:Any)->Void){
        
        print("URL:- \(url) \nHttpMethod:- \(httpMethod) \nRequest:- \(json)")
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let AFrequest = Alamofire.request(url, method: (httpMethod == "POST" ? .post : .get), parameters: json, encoding: (httpMethod == "POST" ? JSONEncoding.`default` : URLEncoding.methodDependent), headers: headers).validate()
        AFrequest.responseJSON { (response) in
            switch response.result {
            case .success( _):
                print(response.result.value)
                success(response.result.value as AnyObject)
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
}

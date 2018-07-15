//
//  LocationDetailsCell.swift
//  resQ
//
//  Created by sowmya yellapragada on 10/23/17.
//  Copyright © 2017 sowmya.yellapragada. All rights reserved.
//

import UIKit
import MapKit
import AlamofireImage

protocol LocationDetailsCellDelegate:class {
    func directionsTouch(_ location:CLLocation, details:Location?)
}

class LocationDetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    weak var delegate:LocationDetailsCellDelegate?
    
    var lat:Double = 0.0
    var lng:Double = 0.0
    var loc:Location? = nil
    
    @IBAction func callTouch(_ sender: Any) {
    }
    @IBAction func directionsTouch(_ sender: Any) {
        self.delegate?.directionsTouch(CLLocation(latitude: lat, longitude: lng), details:loc)
    }
    
    func config(loc:Location, initialLocation:CLLocation){
        self.loc = loc
        titleLbl.text = loc.title
        locationLbl.text = loc.locationName
        lat = loc.coordinate.latitude
        lng = loc.coordinate.longitude
        let helpLoc = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)

        let d = helpLoc.distance(from: initialLocation)*0.000621371
        distance.text = String(format:"%.2f", d) + " miles"
        timeLbl.text = String(format:"%.2f", (d/20.0)*60.0) + " minutes"
        var dollar=""
        if let price = loc.pricingLevel{
            for _ in 1...price{
                dollar += "$"
            }
        }
        priceLbl.text = dollar
        if let r = loc.rating{
          ratingLbl.text = "Rating: " + String(format:"%.2f", r)
        }
        
        if let img = loc.imgString{
            let urlString = C.URL.imagesAPI+"?maxwidth=400&photoreference="+img+"&key="+Singleton.instance.apiKey
            if let url = URL(string: urlString){
                imageView.af_setImage(withURL: url)
            }
            
        }
        
        
    }
}

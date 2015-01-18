//
//  APIManager.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import CoreLocation
import Alamofire
import UIKit

let root = "http://23.96.49.191/"

class API {
    
    class func postLocationChange(inout #user: Player!, success: ()->()) {
        // TODO: POST
        if let location = user.location {
            let params = [
                "user_id":user.id,
                "lat":location.coordinate.latitude,
                "lon":location.coordinate.longitude
            ]
            let method = Method.POST
            Alamofire.request(method, "\(root)backend/update_loc", parameters: nil)
                .responseJSON { (_, response, json, error) in
                    println(response!.)
                    if let e = error {
                        println(e)
                        user = nil
                    } else {
                        let json = json as NSDictionary
                        var huntLoc: CLLocation?
                        if let huntLat = json["hunt_lat"] as? CLLocationDegrees {
                            if let huntLon = json["hunt_lon"] as? CLLocationDegrees {
                                if let huntID = json["hunt_id"] as? String {
                                    let hunter = Player(id: huntID)
                                    hunter.location = CLLocation(latitude: huntLat, longitude: huntLon)
                                    user.target = hunter
                                }
                            }
                        }
                        if let preyID = json["prey_id"] as? String {
                            let prey = Player(id: preyID)
                            user.hunter = prey
                        }
                    }
            }
        }
    }
    
    class func addUser(location: CLLocation, image: UIImage?, completion: Player -> ()) {
        let params = ["lat":location.coordinate.latitude, "lon":location.coordinate.longitude]
        Alamofire.request(.POST, "\(root)backend/add_user", parameters: params)
            .responseString { _, _, string, _ in
                completion(Player(id: string!))
        }
    }
    
}
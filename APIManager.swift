//
//  APIManager.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import CoreLocation
import Alamofire

let root = "http://23.96.49.191/"

class API {
    
    class func postLocationChange(#user: Player, location: CLLocation) {
        // TODO: POST
        let params = [
            "user_id":user.id,
            "lat":"\(location.coordinate.latitude)",
            "lon":"\(location.coordinate.longitude)"
        ]
        Alamofire.request(.POST, "\(root)backend/update_loc", params)
    }
    
    class func addUser(location: CLLocation, image: UIImage?, completion: Player -> ()) {
        params = [:]
        Alamofire.request(.POST, "\(root)backend/add_user", params)
            .responseString { _, _, string, _ in
                completion(Player(id: string))
        }
    }
}
//
//  APIManager.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import CoreLocation

class API {
    class func postLocationChange(#user: Player, location: CLLocation) {
        // TODO: POST
    }
    
    class func requestNewTarget(#user: Player, completion: (target: Player) -> ()) {
        // TODO: GET
    }
    
    class func registerInitialLocation(location: CLLocation, completion: (currentPlayer: Player) -> ()) {
        // TODO: POST
    }
}
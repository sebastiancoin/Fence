//
//  Player.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import CoreLocation
import UIKit

class Player {
    var image: UIImage?
    var target: Player?
    var hunter: Player?
    var id: String
    
    /*
    var requiredAccuracy: CLLocationAccuracy {
        // if we're playing, bump the accuracy
        return (target != nil || hunter != nil) ? kCLLocationAccuracyBest : kCLLocationAccuracyHundredMeters
    }*/
    
    init(id: String) {
        self.id = id
    }
}
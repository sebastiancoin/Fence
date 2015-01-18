//
//  Player.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import CoreLocation
import UIKit

let kPlayerIDKey = "kPlayerIDKey"

class Player {
    var image: UIImage?
    var target: Player? {
        didSet {
            update?(self)
        }
    }
    var hunter: Player? {
        didSet {
            update?(self)
        }
    }
    var id: String
    var location: CLLocation?
    
    var update: (Player -> ())?
    
    /*
    var requiredAccuracy: CLLocationAccuracy {
        // if we're playing, bump the accuracy
        return (target != nil || hunter != nil) ? kCLLocationAccuracyBest : kCLLocationAccuracyHundredMeters
    }*/
    
    init(id: String) {
        self.id = id
    }
    
    class func currentPlayer() -> Player? {
        let defaults = NSUserDefaults()
        if let playerID = defaults.stringForKey(kPlayerIDKey) {
            return Player(id: playerID)
        } else {
            return nil
        }
    }
    
    func saveAsCurrent() {
        let defaults = NSUserDefaults()
        defaults.setObject(id, forKey: kPlayerIDKey)
    }
}
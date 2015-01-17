//
//  DirectionalView.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import UIKit
import CoreLocation

class DirectionalView: UIView {
    
    var targetLocation: CLLocation? {
        didSet {
            calculateBearing()
        }
    }
    
    var currentLocation: CLLocation? {
        didSet {
            calculateBearing()
        }
    }
    
    func calculateBearing() {
        if let target = targetLocation {
            if let current = currentLocation {
                let dx = current.coordinate.longitude - target.coordinate.longitude
                let dy = current.coordinate.latitude - target.coordinate.latitude
                
                let bearing = atan2(dy, dx)
                
                self.transform = CGAffineTransformMakeRotation(CGFloat(bearing))
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        let radius = (bounds.size.width - 6) / 2
        let a = radius * sqrt(3.0) / 2
        let b = radius / 2
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: -radius))
        path.addLineToPoint(CGPoint(x: a, y: b))
        path.closePath()
    }
}
//
//  DirectionalView.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import UIKit
import CoreLocation

func degreesToRadians(degrees: CLLocationDegrees) -> Double {
    return degrees * M_PI / 180
}

func radiansToDegrees(radians: Double) -> Double {
    return radians * 180 / M_PI
}

func milesToFeet(miles: Double) -> Double {
    return miles * 5280
}

extension CLLocationDistance {
    var miles: Double {
        return self / 1609.344
    }
    
    var feet: Double {
        return milesToFeet(miles)
    }
}

class DirectionalView: UIView {
    
    let buffer = degreesToRadians(10)
    
    var lockedOn: Bool {
        let absAngle = abs(relativeAngle) % (2 * M_PI)
        return absAngle + buffer < 2 * buffer
    }
    
    var relativeAngle: Double = 0.0
    
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
    
    var currentHeading: CLHeading? {
        didSet {
            calculateBearing()
        }
    }
    
    func calculateBearing() {
        if let target = targetLocation {
            if let current = currentLocation {
                if let head = currentHeading {
                    let lat1 = degreesToRadians(current.coordinate.latitude)
                    let lng1 = degreesToRadians(current.coordinate.longitude)
                    let lat2 = degreesToRadians(target.coordinate.latitude)
                    let lng2 = degreesToRadians(target.coordinate.longitude)
                    let deltalng = lng2 - lng1
                    let y = sin(deltalng) * cos(lat2)
                    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltalng)
                    let bearing = (atan2(y, x) + (2 * M_PI)) % (2 * M_PI)
                    relativeAngle = bearing - degreesToRadians(head.trueHeading)
                    transform = CGAffineTransformMakeRotation(CGFloat(relativeAngle))
                    
                    setNeedsDisplay()
                }
            }
        }
    }
    
    
    override func drawRect(rect: CGRect) {
        
        clipsToBounds = false
        
        let width = (bounds.size.width)
        let halfHeight = (width / 2.0)
        
        var dUsers: Double = 0.0
        if let target = targetLocation {
            if let current = currentLocation {
                dUsers = current.distanceFromLocation(target).miles
            }
        }
        
        UIColor.blackColor().setFill()
        if lockedOn {
            UIColor(red: 0, green: 0.5, blue: 0, alpha: 1).setFill()
        }
        let arc = UIBezierPath()
        arc.moveToPoint(CGPoint(x: halfHeight, y: halfHeight))
        arc.addArcWithCenter(CGPoint(x: halfHeight, y: halfHeight),
            radius: halfHeight,
            startAngle: CGFloat(0),
            endAngle: CGFloat(M_PI * 2),
            clockwise: true)
        arc.fill()
    
        var height = (halfHeight * CGFloat(dUsers)) + (0.25 * halfHeight)
        UIColor.greenColor().set()
        
        if dUsers < 0.25  && dUsers > 0.1 {
            height = ((halfHeight * CGFloat(dUsers)) / 0.25) + (0.1 * halfHeight)
            UIColor.yellowColor().set()
            
        } else if dUsers <= 0.1 {
            height = ((halfHeight * CGFloat(dUsers)) / 0.1)
            UIColor.redColor().set()
        }
        

        height = min(height, halfHeight)
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: width, y: halfHeight))
        path.addLineToPoint(CGPoint(x: halfHeight-1, y: 0))
        path.addLineToPoint(CGPoint(x: 1, y: halfHeight))
        path.closePath()
        path.fill()
        
        let context = UIGraphicsGetCurrentContext()
        let stem = CGRect(x: halfHeight - 16, y: halfHeight, width: 32, height: height)
        CGContextFillRect(context, stem)
        
        let dFeet = milesToFeet(dUsers)
        UIColor.blackColor().setStroke()
        var paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .Center
        let label = "\(Int(ceil(dFeet))) ft" as NSString
        label.drawInRect(CGRect(x: 8, y: halfHeight-14, width: width - 16, height: 14),
            withAttributes: [NSParagraphStyleAttributeName:paraStyle])
    }
}
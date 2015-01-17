//
//  FlickView.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import UIKit

class FlickView: UIView {
    @IBOutlet var flickedView: UIView!
    lazy private var gesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self,
        action: "handlePan")
    
    
    var minY: CGFloat {
        return frame.height * 0.25
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translationInView(self)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)
        var f = flickedView.frame
        f.origin = CGPoint(x: f.origin.x, y: f.origin.y + point.y)
        flickedView.frame = f
        if f.origin.y <= minY {
            UIView.animateWithDuration(0.01) {
                self.backgroundColor = UIColor.greenColor()
                var f = self.flickedView.frame
                f.origin.y = -self.flickedView.frame.height
                self.flickedView.frame = f
            }
            return
        }
        if recognizer.state == .Ended {
            
            UIView.animateWithDuration(0.3) {
                self.backgroundColor = UIColor.redColor()
                var f = self.flickedView.frame
                f.origin.y = self.frame.height - self.flickedView.frame.height
                self.flickedView.frame = f
            }
        }
    }
}
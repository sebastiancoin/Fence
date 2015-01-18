//
//  OverlayImageView.swift
//  Fence
//
//  Created by Will on 1/18/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import UIKit

class OverlayImageView: UIView {
    var imageView: UIImageView
    
    func dismiss() {
        UIView.animateWithDuration(0.3,
            animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
        })
    }
    
    init(fromView view: UIView, image: UIImage) {
        imageView = UIImageView()
        imageView.backgroundColor = UIColor.clearColor()
        imageView.opaque = false
        imageView.image = image
        super.init()
        let pop = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
        dispatch_after(pop, dispatch_get_main_queue()) {
            self.imageView.userInteractionEnabled = false
            self.dismiss()
        }
        let tap = UITapGestureRecognizer(target: self, action: "dismiss")
        imageView.addGestureRecognizer(tap)
        imageView.userInteractionEnabled = true
        frame = view.frame
        imageView.frame = frame
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    }

    required init(coder aDecoder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: aDecoder)
    }
}

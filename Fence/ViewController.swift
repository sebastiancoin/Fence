//
//  ViewController.swift
//  Fence
//
//  Created by Arani Bhattacharyay on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import UIKit
import GameKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var compass: DirectionalView!
    @IBOutlet var fireButton: UIButton!
    
    lazy var locationManager: CLLocationManager = {
       let man = CLLocationManager()
        man.delegate = self
        man.desiredAccuracy = kCLLocationAccuracyBest
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            man.requestAlwaysAuthorization()
        case .Denied:
            fallthrough
        case .Restricted:
            UIAlertView(title: "Yo We Need This",
                message: "Without location services, there's no point",
                delegate: nil, cancelButtonTitle: "Dismiss").show()
        default:
            break
        }
        return man
    }()
    
    var addingUser = false
    var currentPlayer: Player!

    var localPlayer: GKLocalPlayer!
    
    var armed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "killed", name: kKilledNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "matched", name: kMatchNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "prey", name: kPreyNotification, object: nil)
        fireButton.enabled = false
        /*
        if let p = Player.currentPlayer() {
            currentPlayer = p
            p.update = {
                self.compass.targetLocation = $0.target?.location
                self.updateFireButtonImage()
            }
        } else {*/
            
        // Do any additional setup after loading the view, typically from a nib.
        // 42.292572, -83.716294
        
        loadLocalPlayer {
            user in
            if let completedUser = user {
                // start game process here!
                completedUser.loadPhotoForSize(GKPhotoSizeNormal) {
                    image, error in
                    // TODO: set image
                    if let _ = error { println(error) }
                }
            } else {
                UIAlertView(title: "we need gamecenter dude", message: nil, delegate: nil, cancelButtonTitle: nil).show()
            }
        }
        //}
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func killed() {
        currentPlayer.target = nil
        currentPlayer.hunter = nil
        compass.targetLocation = nil
        //UIAlertView(title: "You've been killed", message: "you dead", delegate: nil, cancelButtonTitle: "aaah").show()
        OverlayImageView(fromView: view, image: UIImage(named: "Dead")!)
    }
    
    
    func matched() {
        //OverlayImageView(fromView: view, image: UIImage(named: "Lock On Icon")!)
        println("found someone")
    }
    
    func prey() {
        OverlayImageView(fromView: view, image: UIImage(named: "Tracer Icon")!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pop(timeLeft: Int, _ label: UILabel) {
        if timeLeft > 0 {
            label.text = "\(timeLeft) seconds"
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                self.pop(timeLeft - 1, label)
            }
        } else {
            label.removeFromSuperview()
            self.armed = true
            self.updateFireButtonImage()
        }
        
    }
    
    @IBAction func fire(sender: UIButton) {
        let timeOutLabel = UILabel(frame: sender.frame)
        timeOutLabel.textAlignment = .Center
        view.addSubview(timeOutLabel)
        let timeLeft = 15
        armed = false
        updateFireButtonImage()
        pop(timeLeft, timeOutLabel)
        
        if compass.lockedOn {
            // HIT
            API.kill(&currentPlayer!)
            OverlayImageView(fromView: view, image: UIImage(named: "Terminated Icon")!)
            compass.targetLocation = nil
            
        } else {
            // MISS
            UIAlertView(title: "Miss!", message: nil, delegate: nil, cancelButtonTitle: "Okay").show()
        }
    }
    
    func updateFireButtonImage() {
        if armed {
            let me = locationManager.location
            if let target = compass.targetLocation {
                let distance = me.distanceFromLocation(target).feet
                
                if distance <= 50 {
                    fireButton.enabled = true
                } else {
                    fireButton.enabled = false
                }
            } else {
                fireButton.enabled = false
            }
        } else {
            fireButton.enabled = false
        }
    }
    
    // MARK: CL
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            manager.startUpdatingLocation()
        case .AuthorizedWhenInUse:
            fallthrough
        case .Restricted:
            fallthrough
        case .Denied:
            UIAlertView(title: "Yo We Need This",
                message: "Without location services, there's no point",
                delegate: nil, cancelButtonTitle: "Dismiss").show()
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        UIView.animateWithDuration(0.3) {
            self.compass.currentLocation = newLocation
        }
        if currentPlayer == nil && !addingUser &&
            localPlayer != nil && localPlayer.authenticated {
            
                addingUser = true
                API.addUser(localPlayer.playerID, location: newLocation, image: nil) {
                    self.currentPlayer = $0
                    self.currentPlayer.saveAsCurrent()
                    self.currentPlayer.update = {
                        self.compass.targetLocation = $0.target?.location
                        self.updateFireButtonImage()
                        return
                    }
                }
        } else if currentPlayer != nil {
            currentPlayer.location = newLocation
            API.postLocationChange(user: &currentPlayer) {
                UIView.animateWithDuration(0.3) {
                    self.compass.currentLocation = self.currentPlayer.location
                    self.compass.targetLocation = self.currentPlayer.target?.location
                }
            }
        }
        updateFireButtonImage()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        
        // TODO: UPDATE COMPASS
//        UIView.animateWithDuration(0.3) {
//            self.compass.currentHeading = newHeading
//        }
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.99, initialSpringVelocity: 0, options: .allZeros, animations: {
            self.compass.currentHeading = newHeading
            }, completion: nil)
    }
    
    // MARK: GK

    func loadLocalPlayer(completion: GKLocalPlayer? -> ()) {
        localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            authViewController, error in
            if let auth = authViewController {
                self.presentViewController(auth, animated: true, completion: nil)
            } else if self.localPlayer.authenticated {
                completion(self.localPlayer)
            } else {
                completion(nil)
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}


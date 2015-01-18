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
    @IBOutlet var profileImage: UIImageView!
    
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
    var localProfilePic: UIImage?
    var armed = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "killed", name: kKilledNotification, object: nil)
        fireButton.enabled = false
        if let p = Player.currentPlayer() {
            currentPlayer = p
            p.update = {
                self.compass.targetLocation = $0.target?.location
                self.updateFireButtonImage()
            }
        } else {
            
            // Do any additional setup after loading the view, typically from a nib.
            // 42.292572, -83.716294
            
            loadLocalPlayer {
                user in
                if let completedUser = user {
                    // start game process here!
                    completedUser.loadPhotoForSize(GKPhotoSizeNormal) {
                        image, error in
                        // TODO: set image
                        self.localProfilePic = image
                        if let _ = error { println(error) }
                    }
                }
            }
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    func killed() {
        currentPlayer.target = nil
        currentPlayer.hunter = nil
        compass.targetLocation = nil
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
        timeOutLabel.textColor = UIColor.whiteColor()
        view.addSubview(timeOutLabel)
        let timeLeft = 15
        armed = false
        updateFireButtonImage()
        pop(timeLeft, timeOutLabel)
        
        if compass.lockedOn {
            // HIT
            API.kill(&currentPlayer!)
            UIAlertView(title: "Hit!", message: nil, delegate: nil, cancelButtonTitle: "Okay").show()
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
        if currentPlayer == nil && !addingUser {
            addingUser = true
            API.addUser(newLocation, image: nil) {
                self.currentPlayer = $0
                self.currentPlayer.saveAsCurrent()
                self.currentPlayer.update = {
                    self.compass.targetLocation = $0.target?.location
                    self.updateFireButtonImage()
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
        let local = GKLocalPlayer.localPlayer()
        local.authenticateHandler = {
            authViewController, error in
            if let auth = authViewController {
                self.presentViewController(auth, animated: true, completion: nil)
            } else if local.authenticated {
                completion(local)
            } else {
                completion(nil)
            }
        }
    }
    
}


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
    
    var currentPlayer: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let p = Player.currentPlayer() {
            currentPlayer = p
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        // 42.292572, -83.716294

        compass.targetLocation = CLLocation(latitude: 42.292572, longitude: -83.716294)
        loadLocalPlayer {
            user in
            if let completedUser = user {
                // start game process here!
                completedUser.loadPhotoForSize(GKPhotoSizeNormal) {
                    image, error in
                    // TODO: set image
                    //self.currentPlayer.image = image
                    if let _ = error { println(error) }
                }
            }
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        compass.currentLocation = newLocation
        if currentPlayer == nil {
            API.registerInitialLocation(newLocation, completion: {_ in})
        } else {
            API.postLocationChange(user: currentPlayer, location: newLocation)
        }
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


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

    @IBOutlet var targetImageView: UIImageView!
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
        // Do any additional setup after loading the view, typically from a nib.
        compass.targetLocation = CLLocation(latitude: 0, longitude: 0)
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
        
        API.postLocationChange(user: currentPlayer, location: newLocation)
        compass.currentLocation = newLocation
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        
        // TODO: UPDATE COMPASS
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


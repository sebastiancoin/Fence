//
//  APIManager.swift
//  Fence
//
//  Created by Will on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import CoreLocation
import Alamofire
import UIKit

let root = "http://23.96.49.191/backend"

class API {
    
    class func postLocationChange(inout #user: Player!, success: ()->()) {
        // TODO: POST
        if let location = user.location {
            println("userID: \(user.id)")
            let params = [
                "user_id":user.id,
                "lat":location.coordinate.latitude,
                "lon":location.coordinate.longitude
            ] as [String:AnyObject]
            println(params)
            Alamofire.request(.POST, "\(root)/update_loc", parameters: params)
                .responseString {
                    _, _, str, err in
                    println(str!)
                }
                .responseJSON { (_, response, jsonDict, error) in
                    if let e = error {
                        println("err: \(e)")
                        user = nil
                    } else {
                        let json: NSDictionary = jsonDict as NSDictionary
                        println("json: \(json)")
                        
                        if let killed = json["Life"] as? String {
                            if killed == "DEAD" {
                                let notif = UILocalNotification()
                                notif.repeatInterval = NSCalendarUnit(0)
                                notif.soundName = UILocalNotificationDefaultSoundName
                                notif.alertBody = "You dead!"
                                notif.userInfo = [kNotifType:kKilledNotification]
                                UIApplication.sharedApplication().presentLocalNotificationNow(notif)
                                return
                            }
                        }
                        
                        var hunter: Player?
                        if let huntLat = json["hunt_lat"] as? CLLocationDegrees {
                            if let huntLon = json["hunt_lon"] as? CLLocationDegrees {
                                if let huntID = json["hunt_id"] as? String {
                                    hunter = Player(id: huntID)
                                    hunter!.location = CLLocation(latitude: huntLat, longitude: huntLon)
                                }
                            }
                        }
                        if user.target?.id != hunter?.id {
                            let notif = UILocalNotification()
                            notif.repeatInterval = NSCalendarUnit(0)
                            notif.soundName = UILocalNotificationDefaultSoundName
                            notif.alertBody = "Target acquired!"
                            notif.userInfo = [kNotifType:kMatchNotification]
                            UIApplication.sharedApplication().presentLocalNotificationNow(notif)
                        }
                        user.target = hunter
                        
                        var prey: Player?
                        if let preyID = json["prey_id"] as? String {
                            prey = Player(id: preyID)
                        }
                        
                        if user.hunter?.id != prey?.id {
                            let notif = UILocalNotification()
                            notif.repeatInterval = NSCalendarUnit(0)
                            notif.soundName = UILocalNotificationDefaultSoundName
                            notif.alertBody = "They're near!"
                            notif.userInfo = [kNotifType:kPreyNotification]
                            UIApplication.sharedApplication().presentLocalNotificationNow(notif)
                        }
                        
                        user.hunter = prey
                    }
            }
        }
    }
    
    class func addUser(gcID: String, location: CLLocation, image: UIImage?, completion: Player -> ()) {
        let params = ["lat":location.coordinate.latitude, "lon":location.coordinate.longitude, "name":gcID] as [String:NSObject]
        Alamofire.request(.POST, "\(root)/add_user", parameters: params)
            .responseString { _, _, string, _ in
                println(params)
                println(string)
                completion(Player(id: string!))
        }
    }
    
    class func kill(inout user: Player) {
        user.target = nil
        let params = ["user_id":user.id] as [String:AnyObject]
        Alamofire.request(.POST, "\(root)/killed", parameters: params)
            .responseString { _, _, str, err in println(str) }
    }
    
    
}
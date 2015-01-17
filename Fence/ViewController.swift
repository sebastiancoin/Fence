//
//  ViewController.swift
//  Fence
//
//  Created by Arani Bhattacharyay on 1/17/15.
//  Copyright (c) 2015 Arani Bhattacharyay. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {

    @IBOutlet var targetImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadLocalPlayer {
            user in
            if let completedUser = user {
                // start game process here!
                println(completedUser)
                completedUser.loadPhotoForSize(GKPhotoSizeSmall) {
                    image, error in
                    self.targetImageView.image = image
                    if let _ = error { println(error) }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


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


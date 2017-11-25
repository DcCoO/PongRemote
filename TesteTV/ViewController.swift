/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Handles keyboard (OS X), touch (iOS) and controller (iOS, tvOS) input for controlling the game.
 */

import UIKit
import GameController

class ViewController: UIViewController {
    
    var velocidade: CGFloat! = 0
    
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var velLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDidConnect), name: Notification.Name.GCControllerDidConnect, object: nil)
        
        //remoteView.transform = CGAffineTransform.identity.rotated(by: degreesToRadians(degrees: 45))
    }
    
    //REMOTE
    func initRemote(){
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(controllerDidConnect),
                                               name: Notification.Name.GCControllerDidConnect,
                                               object: nil)
    }
    
    @objc func controllerDidConnect(notification: NSNotification) {
        let gameController = notification.object as? GCController
        if gameController != nil {
            Remote.sharedInstance.controller = gameController
        }
        
        // +90 --- -90
        //  -1 --- +1
        //  __________
        // |     menu |
        // |_____ [] _|
        
        if let controller = Remote.sharedInstance.controller {
            if let motion = controller.motion {
                motion.valueChangedHandler = { (motion) -> Void in
                    let angle = controller.rotation(motion: motion)
                    if(90 < angle && angle < 180){
                        self.velocidade = self.negativeSpeed(angle: CGFloat(angle))
                    }
                    else if(-90 > angle && angle > -180){
                        self.velocidade = self.positiveSpeed(angle: CGFloat(angle))
                    }
                    
                    //print(self.velocidade)
                    self.label.text = String(describing: angle)
                    self.velLabel.text = String(describing: self.velocidade)
                    
                    self.remoteView.transform = CGAffineTransform.identity.rotated(by:self.degreesToRadians(degrees: 90.0 * (self.velocidade)))
                }
            } else {
                print("no motion")
            }
        } else {
            print("no controller")
        }
    }
    
    var atenuante: CGFloat = 1.6  // < 90
    
    func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(Double.pi) / 180
    }
    
    func negativeSpeed(angle: CGFloat) -> CGFloat {
        //angulo entre 90(-1) e 180(0)
        let speed = (180.0 - angle) / (90.0)
        return -speed/atenuante
    }
    
    func positiveSpeed(angle: CGFloat) -> CGFloat {
        //angulo entre -90(1) e -180(0)
        let speed = (-180.0 - angle) / (-90.0)
        return speed/atenuante
    }
}



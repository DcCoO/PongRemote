//
//  Remote.swift
//  TesteTV
//
//  Created by Daniel Cauás on 17/11/17.
//  Copyright © 2017 Daniel Cauás. All rights reserved.
//

import Foundation
import GameController

class Remote {
    
    var controller: GCController?
    var previousTenPoints: [CGPoint]?
    var lastTenPoints: [CGPoint]?
    
    static let sharedInstance = Remote()
    
    private init() {
        // Prevent public init because of singleton
        previousTenPoints = [CGPoint]()
        lastTenPoints = [CGPoint]()
    }
}

extension GCController {
    
    func rotation(motion: GCMotion) -> Double {
        
        //print("Acceleration \(motion.userAcceleration) \nGravity: \(motion.gravity)")
        
        var previousTenPoints = Remote.sharedInstance.previousTenPoints!
        var lastTenPoints = Remote.sharedInstance.lastTenPoints!
        
        // Setting last 10 locations of remote as CGPoint
        if (previousTenPoints.count <= 10) {
            previousTenPoints.append(CGPoint(x: motion.gravity.x * 1000, y: motion.gravity.y * 1000))
        } else {
            previousTenPoints.removeFirst()
            previousTenPoints.append(lastTenPoints[0])
        }
        
        /*
         * This is the second positions of remote of each motion. So we can get average movement on coordinate plane
         * Here we think user have only two dimensional movement like steering wheel
         * So we don't calculate any z direction movement
         */
        if (lastTenPoints.count <= 10) {
            lastTenPoints.append(CGPoint(x: motion.gravity.x * 1000, y: motion.gravity.y * 1000))
        } else {
            lastTenPoints.removeFirst()
            lastTenPoints.append(CGPoint(x: motion.gravity.x * 1000, y: motion.gravity.y * 1000));
        }
        
        var previousAvgX = 0.0, previousAvgY = 0.0, lastAvgX = 0.0, lastAvgY = 0.0
        
        // Calculating average location on coordinate plane for last 10 and previous 10 movement action
        for i in 0 ..< previousTenPoints.count {
            
            let previousPoint = previousTenPoints[i]
            let lastPoint = lastTenPoints[i]
            
            previousAvgX = (previousAvgX + Double(previousPoint.x)) / 2;
            previousAvgY = (previousAvgY + Double(previousPoint.y)) / 2;
            
            lastAvgX = Double(lastPoint.x) / 2
            //lastAvgX = (lastAvgX + Double(lastPoint.x)) / 2;
            //lastAvgY = (lastAvgY + Double(lastPoint.y)) / 2;
        }
        
        // Calculating difference between last and previous positions
        let deltaY = lastAvgY - previousAvgY;
        let deltaX = lastAvgX - previousAvgX;
        
        // Calculating arctangent of delta line and then converting radian to degree
        let angleInDegrees = atan2(deltaY, deltaX) * 180 / M_PI;
        
        //print("Angle in degrees: \(angleInDegrees)")
        
        Remote.sharedInstance.previousTenPoints = previousTenPoints
        Remote.sharedInstance.lastTenPoints = lastTenPoints
        
        return angleInDegrees
    }
}

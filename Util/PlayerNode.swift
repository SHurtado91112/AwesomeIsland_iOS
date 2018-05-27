//
//  PlayerNode.swift
//  AwesomeIsland_iOS
//
//  Created by Steven Hurtado on 5/26/18.
//  Copyright © 2018 Steven Hurtado. All rights reserved.
//

import Foundation
import SceneKit

final class PlayerNode {
    public var node : SCNNode?
    
    let speed: Float = 0.1
    
    var directionAngle: SCNFloat = 0.0 {
        didSet {
            if directionAngle != oldValue {
                // action that rotates the node to an angle in radian.
                let action = SCNAction.rotateTo(
                    x: 0.0,
                    y: CGFloat(directionAngle),
                    z: 0.0,
                    duration: 0.1, usesShortestUnitArc: true
                )
                self.node?.runAction(action)
            }
        }
    }
    
    func walkInDirection(_ direction: float3) {
        if let node = self.node
        {
            let currentPosition = float3(node.position)
            self.node?.position = SCNVector3(currentPosition + direction * speed)
        }
    }
}


//
//  Game.swift
//  AwesomeIsland_iOS
//
//  Created by Steven Hurtado on 5/27/18.
//  Copyright © 2018 Steven Hurtado. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit

class Game {
    
    //NODES
    var baseRig = SCNNode() // used for applying animation to current character
    var player = PlayerNode() // current playable character, handles positioning and holds ref node
    var cameraNode = SCNNode() // camera for our character
    let cameraOffset = Float(24)
    
    //SCENES
    var baseScene = SCNScene()
    var baseCharacter = SCNScene()
    
    
    //ANIMATIONS
    var idleAnimation = SCNAnimationPlayer()
    var runAnimation = SCNAnimationPlayer()
    
    public var currentState = 0
    public var LevelStates = [
        ("Level", 0)
    ]
    
    //for every level, define characters needed, starting positions as well, the first character should be the playable character
    public var Characters = [
        [
            ("Steven", SCNVector3(x: 0, y: 0, z: 0))
        ]
    ]
    
    //state handler
    func setUpScene() -> SCNScene?
    {
        //get current state
        let state = LevelStates[currentState]
        let stateType = state.0 //Level mode or cutscene mode
        let stateIndex = state.1 //index of level or cutscene
        
        switch(stateType)
        {
            case "Level":
                goToLevel(index: stateIndex)
            break;
            default:
            break;
        }
        
        return self.baseScene
    }
    
    func getLevelFrom(index: Int) -> Level
    {
        var level = Level()
        switch(index)
        {
            case 0:
                //level one
                level = Level1.Get()
                break;
            default:
                break;
        }
        return level
    }
    
    func goToLevel(index: Int) {
        let level = getLevelFrom(index: index)
        // create a new scene
        self.baseScene = SCNScene(named: level.SceneName)!
        self.baseCharacter = SCNScene(named: level.BaseCharacter)!
        setUpAnimations()
        
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        baseScene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 6, z: 24)
        
        let children = self.baseCharacter.rootNode.childNodes
        for child in children {
            self.baseScene.rootNode.addChildNode(child)
        }
        
        // stop it for now so that we can use it later when it's appropriate
        self.runAnimation.stop()
        
        //assign player's node to node that handles movement
        self.player.node = self.baseScene.rootNode.childNode(withName: level.BaseRig, recursively: true)
    }
    
    func setUpAnimations() {
        //get current idle animation
        for pair in SCNAnimationPlayer.getAnimationKeys(scene: self.baseCharacter) {
            print(pair.0)
            print(pair.1)
            switch(pair.0)
            {
            case "BaseIdle-1":
                self.idleAnimation = pair.1.animationPlayer(forKey: pair.0)!
                baseRig = pair.1
                break;
            default:
                break;
            }
        }
        
        //apply additional animation
        for pair in SCNAnimationPlayer.getAnimationKeys(scene: SCNScene(named: "art.scnassets/BaseRun.dae")!) {
            print(pair.0)
            print(pair.1)
            switch(pair.0)
            {
            case "BaseRun-1":
                self.runAnimation = pair.1.animationPlayer(forKey: pair.0)!
                baseRig.addAnimationPlayer(self.runAnimation, forKey: "BaseRun-1")
                break;
            default:
                break;
            }
        }
    }
    
    func controlPlayer(direction: float2)
    {
        let degree = atan2(direction.x, direction.y)
        player.directionAngle = degree
        
        let directionInV3 = float3(x: direction.x, y: 0, z: direction.y)
        player.walkInDirection(directionInV3)
        
        if let playerNodePositionX = player.node?.presentation.position.x, let playerNodePositionZ = player.node?.presentation.position.z
        {
            cameraNode.position.x = playerNodePositionX
            cameraNode.position.z = playerNodePositionZ + cameraOffset
        }
    }
}

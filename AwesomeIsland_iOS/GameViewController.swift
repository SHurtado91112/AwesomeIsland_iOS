//
//  GameViewController.swift
//  AwesomeIsland_iOS
//
//  Created by Steven Hurtado on 5/25/18.
//  Copyright © 2018 Steven Hurtado. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    //NODES
    var baseRig = SCNNode()
    var player = PlayerNode()
    var cameraNode = SCNNode()
    
    //SCENES
    var baseScene = SCNScene()
    var baseCharacter = SCNScene()
    var sceneView = SCNView()
    
    //ANIMATIONS
    var idleAnimation = SCNAnimationPlayer()
    var runAnimation = SCNAnimationPlayer()
    
    //CHILD VIEW CONTROLLERS
    var hudViewController : HUDViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve the character node
        self.baseCharacter = SCNScene(named: "art.scnassets/BaseIdle.dae")!
        
        setUpAnimations()
        
        setUpScene()
    
        setUpChildControllers()
        
        //test for movement
        testMovement()
    }
    
    func testMovement() {
        self.baseCharacter.rootNode.rotation = SCNVector4(0, 0, 1, Float(45).degreesToRadians)
        self.baseScene.rootNode.rotation = SCNVector4(0, 0, 1, Float(45).degreesToRadians)
        self.baseRig.rotation = SCNVector4(0, 0, 1, Float(45).degreesToRadians)
        
        // action that rotates the node to an angle in radian.
        let action = SCNAction.rotateTo(
            x: 0.0,
            y: 1.6,
            z: 0.0,
            duration: 0.1, usesShortestUnitArc: true
        )
        self.baseRig.runAction(action)
    }
    
    func setUpScene() {
        // create a new scene
        self.baseScene = SCNScene(named: "art.scnassets/BaseArea.scn")!
        
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        baseScene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 6, z: 24)
        self.player.node = self.baseCharacter.rootNode.childNode(withName: "Base", recursively: true)
        
        let children = self.baseCharacter.rootNode.childNodes
        for child in children {
            self.baseScene.rootNode.addChildNode(child)
        }
        
        // stop it for now so that we can use it later when it's appropriate
        self.runAnimation.stop()
        
        //baseScene.rootNode.addChildNode(self.player?.node)
        
        // retrieve the SCNView
        sceneView = self.view as! SCNView
        
        // set the scene to the view
        sceneView.scene = baseScene
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        sceneView.showsStatistics = false
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
    
    func setUpChildControllers() {
        self.hudViewController = HUDViewController()
        self.hudViewController?.delegate = self
        
        self.hudViewController?.addToParent(parent: self)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    func ControlPlayer(direction: float2)
    {
        let degree = atan2(direction.x, direction.y)
        self.player.directionAngle = degree
        print(direction)
        print(degree)
        
        let directionInV3 = float3(x: direction.x, y: 0, z: direction.y)
        self.player.walkInDirection(directionInV3)
        
        //cameraNode.position.x = self.player.presentation.position.x
        //cameraNode.position.z = self.player.presentation.position.z + 24//needs offset maybe
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}

extension GameViewController: HUDControlDelegate {
    func joyStickBegan() {
        print("Joy STICK Began")
        self.idleAnimation.stop()
        self.runAnimation.play()
    }
    
    func joyStickMove(direction: float2) {
        //move based on direction
//        print("ANGLE: \(angle)")
//        print("DISPLACEMENT: \(displacement)")
        ControlPlayer(direction: direction)
    }
    
    func joyStickEnd() {
        print("Joy STICK End")
        self.runAnimation.stop()
        self.idleAnimation.play()
    }
    
    
}

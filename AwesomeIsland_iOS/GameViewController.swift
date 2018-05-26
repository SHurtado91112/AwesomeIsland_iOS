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
    var base = SCNNode()
    
    //SCENES
    var baseScene = SCNScene()
    var baseCharacter = SCNScene()
    
    //ANIMATIONS
    var idleAnimation = SCNAnimationPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        self.baseScene = SCNScene(named: "art.scnassets/BaseArea.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        baseScene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 12, z: 24)
        
        // retrieve the character node
        self.baseCharacter = SCNScene(named: "art.scnassets/BaseIdle.dae")!
        
        for pair in SCNAnimationPlayer.getAnimationKeys(scene: self.baseCharacter) {
            print(pair.0)
            switch(pair.0)
            {
                case "BaseIdle-1":
                    self.idleAnimation = pair.1.animationPlayer(forKey: pair.0)!
                    break;
                default:
                    break;
            }
        }
        
        // animate the 3d object
        self.base = self.baseCharacter.rootNode.childNode(withName: "Base", recursively: true)!
        self.baseRig = self.baseCharacter.rootNode.childNode(withName: "BaseRig", recursively: true)!
        
        let children = self.baseCharacter.rootNode.childNodes
        for child in children {
            self.baseScene.rootNode.addChildNode(child)
        }
        
        self.idleAnimation.stop() // stop it for now so that we can use it later when it's appropriate
        
        baseScene.rootNode.addChildNode(self.base)
        baseScene.rootNode.addChildNode(self.baseRig)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = baseScene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let delayInSeconds = 2.4
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.idleAnimation.play()
        }
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

extension SCNAnimationPlayer {
    class func getAnimationKeys(scene: SCNScene) -> [(String, SCNNode)] {
        var keys = [(String, SCNNode)]()
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                keys.append((child.animationKeys[0], child))
            }
        }
        return keys
    }
    
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
}

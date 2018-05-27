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
    //main scene
    var sceneView = SCNView()
    
    //CHILD VIEW CONTROLLERS
    var hudViewController : HUDViewController?
    var game : Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // instantiate the game
            //the Game class handles the different states of the game, and holds the base components for every view
        game = Game()
        
        // retrieve the SCNView
        sceneView = self.view as! SCNView
        sceneView.scene = game?.setUpScene()
        
        // allows the user to manipulate the camera, set to false
        sceneView.allowsCameraControl = false
        
        // show statistics such as fps and timing information, set to false
        sceneView.showsStatistics = false
        setUpChildControllers()
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
    //control game based ui events from hud
    func joyStickBegan() {
        game?.idleAnimation.stop()
        game?.runAnimation.play()
    }
    
    func joyStickMove(direction: float2) {
        //move based on direction
        game?.controlPlayer(direction: direction)
    }
    
    func joyStickEnd() {
        game?.runAnimation.stop()
        game?.idleAnimation.play()
    }
    
    
}

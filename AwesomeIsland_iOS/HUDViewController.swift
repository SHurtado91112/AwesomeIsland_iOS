//
//  HUDViewController.swift
//  AwesomeIsland_iOS
//
//  Created by Steven Hurtado on 5/26/18.
//  Copyright © 2018 Steven Hurtado. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

protocol HUDControlDelegate {
    //joy stick control
    func joyStickBegan()
    func joyStickMove(direction: float2)
    func joyStickEnd()
}

class HUDViewController: UIViewController {
    //delegate
    var delegate: HUDControlDelegate?
    
    //joy stick components
    var joyStickView : JoyStickView!
    var joyStickInUse = false
    var joyStickDirection = float2.init()
    
    //action buttons
    var actionButtonContainer : UIStackView?
    var jumpButton : UIButton?
    var actionButton : UIButton?
    
    //health view
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func SetUpViews() {
        
        // Create 'fixed' joystick
        let size = CGSize(width: 100.0, height: 100.0)
        let joystickFrame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        joyStickView = JoyStickView(frame: joystickFrame.offsetBy(dx: 60.0, dy: 0.0))
        joyStickView.parent = self
        view.addSubview(joyStickView)
        joyStickView.movable = false
        joyStickView.alpha = 1.0
        joyStickView.baseAlpha = 0.5 // let the background bleed thru the base
        // Show the joystick's orientation in the labels
        //
        joyStickView.monitor = { (direction: float2) in
            self.joyStickDirection = direction
        }

//
//        //joy stick components
//        JoyStickBack = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        guard let jsBack = JoyStickBack else {return}
//
//        jsBack.backgroundColor = UIColor.FlatColor.Gray.IronGray
//        UIButton.setRounded(view: jsBack)
//        UIButton.addShadow(view: jsBack)
//
//        JoyStickView = UIView(frame: CGRect(x: 0, y: 0, width: 84, height: 84))
//        guard let joyStick = JoyStickView else {return}
//
//        joyStick.backgroundColor = UIColor.FlatColor.Gray.AlmondFrost
//        UIButton.setRounded(view: joyStick)
//        UIButton.addShadow(view: joyStick)
        
        //add views
//        self.view.addSubview(jsBack)
//        self.view.addSubview(joyStick)
    }
    
    func SetUpConstraints() {
        //constraints for joystick components
        joyStickView.translatesAutoresizingMaskIntoConstraints = false
        joyStickView.widthAnchor.constraint(equalToConstant: joyStickView.frame.width
            ).isActive = true
        joyStickView.heightAnchor.constraint(equalToConstant: joyStickView.frame.height
            ).isActive = true
        
        joyStickView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        joyStickView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func addToParent(parent: UIViewController) {
        guard let hudView = self.view else {return}
        
        self.willMove(toParentViewController: parent)
        hudView.backgroundColor = UIColor.clear
        parent.view.addSubview(hudView)
        self.didMove(toParentViewController: parent)
        
        //constraints on hud
        hudView.translatesAutoresizingMaskIntoConstraints = false
        hudView.trailingAnchor.constraint(equalTo: parent.view.layoutMarginsGuide.trailingAnchor).isActive = true
        hudView.leadingAnchor.constraint(equalTo: parent.view.layoutMarginsGuide.leadingAnchor).isActive = true
        hudView.bottomAnchor.constraint(equalTo: parent.view.layoutMarginsGuide.bottomAnchor).isActive = true
        hudView.topAnchor.constraint(equalTo: parent.view.layoutMarginsGuide.topAnchor).isActive = true
        
        //draw views
        SetUpViews()
        
        //set up constraints
        SetUpConstraints()
        
        hudView.layoutSubviews()
    }
    
    //TOUCH CONTROLS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        
        //hit test for joystick
        if let targetView = touch.view {
            if(targetView == self.joyStickView)
            {
                
            }
        }
    }
    
    func touchesBeganFromJoyStick(_ touches: Set<UITouch>, with event: UIEvent?) {
        joyStickInUse = true
        delegate?.joyStickBegan()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(joyStickInUse)
        {
            delegate?.joyStickMove(direction: self.joyStickDirection)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(joyStickInUse) {
            delegate?.joyStickEnd()
            joyStickInUse = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

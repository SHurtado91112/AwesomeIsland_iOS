//
//  Level1.swift
//  AwesomeIsland_iOS
//
//  Created by Steven Hurtado on 5/27/18.
//  Copyright © 2018 Steven Hurtado. All rights reserved.
//

import Foundation

class Level1 {
    
    public static func Get() -> Level
    {
        let level = Level()
        level.SceneName = "art.scnassets/BaseArea.scn"
        level.BaseCharacter = "art.scnassets/BaseIdle.dae"
        level.BaseRig = "Rig"
        
        return level
    }
}

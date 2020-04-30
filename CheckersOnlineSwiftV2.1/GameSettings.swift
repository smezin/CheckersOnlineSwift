//
//  GameSettings.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

protocol SettingsData {
    static var settings:GameSettings {get set}
}

class GameSettings: NSObject {

    var sideMarginConstraint: Int
    var topMarginConstraint: Int
    var soundOn: Bool
    var playWhites: Bool
    var playBottom: Bool
    var showPaths: Bool
    
    override init ()
    {
        self.soundOn = true
        self.playWhites = true
        self.playBottom = true
        self.showPaths = true
        let screenSize: CGRect = UIScreen.main.bounds
        
        self.sideMarginConstraint = Int(screenSize.size.width * 0.03)
        self.topMarginConstraint = Int(screenSize.size.height * 0.1)
    }
}


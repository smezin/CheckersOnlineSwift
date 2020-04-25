//
//  GameSettings.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class GameSettings: NSObject {

    var colorOne: UIColor
    var colorTwo: UIColor
    var sideMarginConstraint: Int
    var topMarginConstraint: Int
    var soundOn: Bool
    var playWhites: Bool
    
    init (_ colorOne:UIColor, _ colorTwo:UIColor)
    {
        self.colorOne = colorOne
        self.colorTwo = colorTwo
        self.soundOn = true
        self.playWhites = true
        let screenSize: CGRect = UIScreen.main.bounds
        
        self.sideMarginConstraint = Int(screenSize.size.width * 0.03)
        self.topMarginConstraint = Int(screenSize.size.height * 0.1)
    }
    convenience override init ()
    {
        let colorOne:UIColor = .systemYellow
        let colorTwo:UIColor = .brown
        self.init(colorOne, colorTwo)
    }
}


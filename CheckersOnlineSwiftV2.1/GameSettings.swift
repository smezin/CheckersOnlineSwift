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
    var bounceHeight: Int
    var soundOn: Bool
    var playWhites: Bool
    var playBottom: Bool
    var showPaths: Bool
    var darkSquareImageName:String
    var lightSquareImageName:String
    var pathMarkImageName:String
    var whitePawnImage:String
    var blackPawnImage:String
    var whiteQueenImage:String
    var blackQueenImage:String
    var headerViewId:String
    var footerViewId:String
    
    override init ()
    {
        self.soundOn = true
        self.playWhites = true
        self.playBottom = true
        self.showPaths = true
        self.darkSquareImageName = "wood_dark"
        self.lightSquareImageName = "wood_light"
        self.pathMarkImageName = "path_mark"
        self.whitePawnImage = "white_pawn"
        self.blackPawnImage = "black_pawn"
        self.whiteQueenImage = "white_queen"
        self.blackQueenImage = "black_queen"
        self.headerViewId = "HeaderView"
        self.footerViewId = "FooterView"
        let screenSize: CGRect = UIScreen.main.bounds
        self.sideMarginConstraint = Int(screenSize.size.width * 0.03)
        self.topMarginConstraint = Int(screenSize.size.height * 0.05)
        self.bounceHeight = Int(screenSize.size.width/8)/5
    }
}


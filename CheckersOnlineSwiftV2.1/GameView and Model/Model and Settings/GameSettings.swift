//
//  GameSettings.swift
//  CheckersOnlineSwiftV2.1


import UIKit
import AVFoundation

protocol SettingsData {
    static var settings:GameSettings {get}
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
    var headerHeight:CGFloat
    var footerViewId:String
    var footerHeight:CGFloat
    var moveSoundID: SystemSoundID
    var pickSoundID: SystemSoundID
    var BoardReceivedSoundID: SystemSoundID
    
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
        self.moveSoundID = 1016
        self.pickSoundID = 1010
        self.BoardReceivedSoundID = 1016
        let screenSize: CGRect = UIScreen.main.bounds
        self.sideMarginConstraint = Int(screenSize.size.width * 0.03)
        self.topMarginConstraint = Int(screenSize.size.height * 0.05)
        self.headerHeight = CGFloat(screenSize.size.height / 8)
        self.footerHeight = CGFloat(screenSize.size.height / 6)
        self.bounceHeight = Int(screenSize.size.width/8)/5
    }
}


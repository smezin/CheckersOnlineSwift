//
//  GameSettingsViewController.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class GUISettingsViewController: UIViewController {
    
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var playWhitesSwitch: UISwitch!
    @IBOutlet weak var showPathsSwitch: UISwitch!
    @IBOutlet weak var playBottomSwitch: UISwitch!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var playImageView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        playImageView.center.y -= CGFloat(GameViewController.settings.bounceHeight)*2
        UIImageView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.2, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.playImageView.center.y += CGFloat(GameViewController.settings.bounceHeight)*2
        }) { (success:Bool) in
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
         if (segue.identifier == "loadGame") {
            let settings = GameSettings()
            settings.soundOn = soundSwitch.isOn
            settings.playWhites = playWhitesSwitch.isOn
            settings.showPaths = showPathsSwitch.isOn
            settings.playBottom = playBottomSwitch.isOn
            GameViewController.settings = settings;
            
        }
    }
}

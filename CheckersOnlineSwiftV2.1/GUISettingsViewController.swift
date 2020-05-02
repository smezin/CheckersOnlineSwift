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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

//
//  GameSettingsViewController.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class GameSettingsViewController: UIViewController {
    
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
//            guard let gameVC:GameViewController = segue.destination as? GameViewController else {
//                return
//            }
            GameViewController.settings = settings;
            
        }
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

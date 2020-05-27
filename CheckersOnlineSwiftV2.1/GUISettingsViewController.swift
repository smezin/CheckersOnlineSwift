//
//  GameSettingsViewController.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class GUISettingsViewController: UIViewController {
    
    @IBOutlet weak var loginPlayButton: UIButton!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var playWhitesSwitch: UISwitch!
    @IBOutlet weak var showPathsSwitch: UISwitch!
    @IBOutlet weak var playBottomSwitch: UISwitch!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var playImageView: UIButton!
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nc.addObserver(self, selector: #selector(changeToPlayButton), name: .loginSuccess, object: nil)
        nc.addObserver(self, selector: #selector(changeToLoginButton), name: .loginFailure, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.playImageView.center.y -= CGFloat(GameViewController.settings.bounceHeight)*2
        UIImageView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.2, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
           self.playImageView.center.y += CGFloat(GameViewController.settings.bounceHeight)*2
        }) { (success:Bool) in
        }
    }
    
    @objc func changeToPlayButton () {
        DispatchQueue.main.async {
            self.loginPlayButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    @objc func changeToLoginButton () {
        DispatchQueue.main.async {
            self.loginPlayButton.setImage(UIImage(named: "login"), for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
     //    if (segue.identifier == "loadGame") {
            let settings = GameSettings()
            settings.soundOn = soundSwitch.isOn
            settings.playWhites = playWhitesSwitch.isOn
            settings.showPaths = showPathsSwitch.isOn
            settings.playBottom = playBottomSwitch.isOn
            GameViewController.settings = settings;            
    //    }
    }
    
    @IBAction func tempLogin(_ sender: Any) {
        
//        UserDefaults.standard.set("iPhone11pro", forKey: "userName")
//        UserDefaults.standard.set("abcd1234", forKey: "password")
//        let defaults = UserDefaults.standard
//        let playerName = defaults.string(forKey: "userName")
//        let password = defaults.string(forKey: "password")
//        let user: [String: Any] = ["userName": playerName!,
//        "password": password!]
        PlayersViewController.shared.getAllUsers()
    }
}

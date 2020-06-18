
import UIKit

class GUISettingsViewController: UIViewController {
    
    @IBOutlet weak var loginPlayButton: UIButton!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var playWhitesSwitch: UISwitch!
    @IBOutlet weak var showPathsSwitch: UISwitch!
    @IBOutlet weak var playBottomSwitch: UISwitch!
    @IBOutlet weak var playImageView: UIButton!
    let nc = NotificationCenter.default
    let defaults = UserDefaults.standard
    var isLoggedin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nc.addObserver(self, selector: #selector(changeToPlayButton), name: .loginSuccess, object: nil)
        nc.addObserver(self, selector: #selector(changeToLoginButton), name: .loginFailure, object: nil)
        nc.addObserver(self, selector: #selector(changeToLoginButton), name: .logout, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.playImageView.center.y -= CGFloat(GameViewController.settings.bounceHeight)*2
        UIImageView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.2, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.playImageView.center.y += CGFloat(GameViewController.settings.bounceHeight)*2
        }) { (success:Bool) in
        }
        if defaults.object(forKey: "soundOn") != nil {
            self.soundSwitch.setOn(defaults.bool(forKey: "soundOn"), animated: true)
        }
        if defaults.object(forKey: "playWhites") != nil {
            self.playWhitesSwitch.setOn(defaults.bool(forKey: "playWhites"), animated: true)
        }
        if defaults.object(forKey: "showPaths") != nil {
            self.showPathsSwitch.setOn(defaults.bool(forKey: "showPaths"), animated: true)
        }
        if defaults.object(forKey: "playBottom") != nil {
            self.playBottomSwitch.setOn(defaults.bool(forKey: "playBottom"), animated: true)
        }
    }
    
    @objc func changeToPlayButton () {
        self.isLoggedin = true
        DispatchQueue.main.async {
            self.loginPlayButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }
    @objc func changeToLoginButton () {
        self.isLoggedin = false
        DispatchQueue.main.async {
            self.loginPlayButton.setImage(UIImage(named: "login"), for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        self.updatePlayerPreferences()
    }
    
    func updatePlayerPreferences () {
        defaults.set(soundSwitch.isOn as Bool, forKey: "soundOn")
        defaults.set(playWhitesSwitch.isOn as Bool, forKey: "playWhites")
        defaults.set(showPathsSwitch.isOn as Bool, forKey: "showPaths")
        defaults.set(playBottomSwitch.isOn as Bool, forKey: "playBottom")
    }
    
    
    @IBAction func loginPlayButton(_ sender: Any) {
        self.updatePlayerPreferences()
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if self.isLoggedin {
            let playersView  = storyBoard.instantiateViewController(withIdentifier: "playersID") as! PlayersViewController
            self.present(playersView, animated: true, completion: nil)
        } else {
            let loginView  = storyBoard.instantiateViewController(withIdentifier: "loginID") as! LoginViewController
            loginView.modalPresentationStyle = .fullScreen
            self.present(loginView, animated: true, completion: nil)
        }
        
    }
}

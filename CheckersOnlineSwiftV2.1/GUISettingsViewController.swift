
import UIKit

class GUISettingsViewController: UIViewController {
    
    @IBOutlet weak var loginPlayButton: UIButton!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var playWhitesSwitch: UISwitch!
    @IBOutlet weak var showPathsSwitch: UISwitch!
    @IBOutlet weak var playBottomSwitch: UISwitch!
    @IBOutlet weak var playImageView: UIButton!
    let nc = NotificationCenter.default
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
        
        let settings = GameSettings()
        settings.soundOn = soundSwitch.isOn
        settings.playWhites = playWhitesSwitch.isOn
        settings.showPaths = showPathsSwitch.isOn
        settings.playBottom = playBottomSwitch.isOn
        GameViewController.settings = settings;
        
    }
    
    
    @IBAction func loginPlayButton(_ sender: Any) {
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if self.isLoggedin {
            let playersView  = storyBoard.instantiateViewController(withIdentifier: "playersID") as! PlayersViewController
            self.present(playersView, animated: true, completion: nil)
        } else {
            let loginView  = storyBoard.instantiateViewController(withIdentifier: "loginID") as! LoginViewController
            self.present(loginView, animated: true, completion: nil)
        }
        
    }
}

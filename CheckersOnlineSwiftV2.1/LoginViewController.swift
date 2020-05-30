

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let defaults = UserDefaults.standard
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = defaults.string(forKey: "userName")
        passwordTextField.text = defaults.string(forKey: "password")
        nameTextField.delegate = self
        passwordTextField.delegate = self
        nc.addObserver(self, selector: #selector(showFailAlert), name: .loginFailure, object: nil)
        nc.addObserver(self, selector: #selector(loginSuccess), name: .loginSuccess, object: nil)
        
    }
    
    @IBAction func connectButton(_ sender: Any) {
        defaults.set(nameTextField.text, forKey: "userName")
        defaults.set(passwordTextField.text, forKey: "password")
        let user: [String: Any] = ["userName": defaults.string(forKey: "userName")! as String,
                                   "password": defaults.string(forKey: "password")! as String]
        PlayersViewController.shared.login(user)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    @objc func showFailAlert () {
        DispatchQueue.main.async {
            self.showAlertMessage("Login failed", "Please check user name and password")
        }
    }
    func showAlertMessage (_ title:String, _ message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    @objc func loginSuccess () {
        DispatchQueue.main.async {
            self.goBackToMainView()
        }
    }
    func goBackToMainView () {
        self.dismiss(animated: true, completion: nil)
    }
}


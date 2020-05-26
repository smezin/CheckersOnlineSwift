

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = defaults.string(forKey: "userName")
        passwordTextField.text = defaults.string(forKey: "password")
        nameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func connectButton(_ sender: Any) {
        defaults.set(nameTextField.text, forKey: "userName")
        defaults.set(passwordTextField.text, forKey: "password")
        let user: [String: Any] = ["userName": defaults.string(forKey: "userName")! as String,
                                   "password": defaults.string(forKey: "password")! as String]
        PlayersViewController.shared.login(user)
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}

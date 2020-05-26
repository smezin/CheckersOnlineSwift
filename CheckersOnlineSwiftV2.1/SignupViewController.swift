
import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var reEnterPassTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        passwordTextField.delegate = self
        reEnterPassTextField.delegate = self
    }
   
    @IBAction func createAccount(_ sender: Any) {
        let defaults = UserDefaults.standard
        PlayersViewController.shared.getAllUsers()
        let allPlayersNames = PlayersViewController.shared.allPlayersNames
        let index = allPlayersNames.firstIndex(of: nameTextField.text!)
        if (index != nil) {
            print("name in use")
            return
        }
        if (passwordTextField.text != reEnterPassTextField.text) {
            print("unmatching passwords")
            return
        }
        if (passwordTextField.text!.count < 6) {
            print("invalid password")
            return
        }
        if (nameTextField.text!.count < 3 || nameTextField.text!.count > 12) {
            print("invalid name")
            return
        }
        defaults.set(nameTextField.text, forKey: "userName")
        defaults.set(passwordTextField.text, forKey: "password")
        let user: [String: Any] = ["userName": defaults.string(forKey: "userName")! as String,
                                   "password": defaults.string(forKey: "password")! as String]
        PlayersViewController.shared.createUser(user)
        self.dismiss(animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}


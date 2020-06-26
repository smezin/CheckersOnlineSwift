
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
   
    @IBAction func gotoRootView(_ sender: Any) {
        self.goBackToMainView()
    }
    @IBAction func createAccount(_ sender: Any) {
        let defaults = UserDefaults.standard
        PlayersViewController.shared.getAllUsers()
        let allPlayersNames = PlayersViewController.shared.allPlayersNames
        let index = allPlayersNames.firstIndex(of: nameTextField.text!)
        if (nameTextField.text!.count < 3 || nameTextField.text!.count > 12) {
            self.showAlert("Invalid player name", "Please choose a name longer than 3 charecters and up to 12 charecters")
            return
        }
        if (index != nil) {
            self.showAlert("Name already in use", "Please choose another name")
            return
        }
        if (passwordTextField.text!.count < 6) {
            self.showAlert("Password too short", "Password must be 6 charcters of more")
            return
        }
        if (passwordTextField.text != reEnterPassTextField.text) {
            self.showAlert("Passwords mismatch", "Please make sure you re-enter password correctly")
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
    
    func showAlert (_ title:String, _ message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    func goBackToMainView () {
        self.dismiss(animated: true, completion: nil)
    }
}


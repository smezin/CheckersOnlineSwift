
import UIKit

//Handle communication with DB
extension PlayersViewController {
    func getAllUsers () {
        let url = self.setURLWithPath(path: "/users")
        let request = self.setRequestTypeWithHeaders(method: "GET", url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let responseJSON = responseJSON as? [[String: Any]] {
                let allPlayersNames:[String] = self.createPlayersNamesList(allPlayers: responseJSON)
                self.allPlayersNames = allPlayersNames
            }
        }
        task.resume()
    }
    func createUser (_ user: [String: Any]) {
        
        let url = self.setURLWithPath(path: "/users")
        var request = self.setRequestTypeWithHeaders(method: "POST", url: url)
        let jsonData = try? JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                PlayersViewController.shared.me = responseJSON
                PlayersViewController.shared.login(PlayersViewController.shared.me)
            }
        }
        task.resume()
    }
    
    func login (_ user: [String: Any]) {
        let user: [String: Any] = ["userName": defaults.string(forKey: "userName")! as String,
                                   "password": defaults.string(forKey: "password")! as String]
        let url = self.setURLWithPath(path: "/users/login")
        var request = self.setRequestTypeWithHeaders(method: "POST", url: url)
        let jsonData = try? JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                PlayersViewController.shared.me = responseJSON
                let responseStatus = responseJSON["status"] as? String
                if (responseStatus == "error") {
                    PlayersViewController.shared.isLoggedIn = false
                    self.nc.post(name: .loginFailure, object: nil)
                } else {
                    PlayersViewController.shared.isLoggedIn = true
                    PlayersViewController.shared.me = responseJSON
                    self.nc.post(name: .loginSuccess, object: nil)
                }
            }
        }
        task.resume()
    }
    
    func logout () {
        self.exitRoom()
        PlayersViewController.shared.isLoggedIn = false
        let url = self.setURLWithPath(path: "/users/logout")
        var request = self.setRequestTypeWithHeaders(method: "POST", url: url)
        let jsonData = try? JSONSerialization.data(withJSONObject: PlayersViewController.shared.me, options: .prettyPrinted)
        PlayersViewController.shared.me = [:]
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
            if (responseJSON as? [String: Any]) != nil {
                self.nc.post(name: .logout, object: nil)
            }
        }
        task.resume()
    }
}

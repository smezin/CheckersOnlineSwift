//
//  PlayersViewController.swift
//
import UIKit
import Foundation
import SocketIO

class PlayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {

   @IBOutlet weak var playersTableView: UITableView!
   let cellReuseIdentifier = "cell"
   var me:[String: Any] = [:]
   var myOpponent:[String:Any] = [:]
   var idlePlayers:[[String:Any]] = []
   var playersAtDispalyFormat:[String] = []
   let scheme = "http"
   let port = 3000
   let host = "localhost"
   
   let user: [String: Any] = ["userName": "iPhone11pro",
                              "password": "abcd1234"]
   
   let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(false), .compress])
    
   
   override func viewDidLoad() {
       super.viewDidLoad()
       self.playersTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
       playersTableView.delegate = self
       playersTableView.dataSource = self
       socketConnect()
 //      self.createUser(user)
   }
   //
    @IBAction func loginB(_ sender: Any) {
        self.login(user)
    }
    @IBAction func conncetB(_ sender: Any) {
        self.enterIdleUsersRoom()
    }
    @IBAction func logoutB(_ sender: Any) {
        self.logout()
    }
    @IBAction func disconnectB(_ sender: Any) {
        self.disconnect()
    }
    
    
       
   //
   
   func createUser (_ user: [String: Any]) {
       
       let url = self.setURLWithPath(path: "/users")
       var request = self.setRequestTypeWithHeaders(method: "POST", url: url)
       let jsonData = try? JSONSerialization.data(withJSONObject: user, options: .prettyPrinted)
       request.httpBody = jsonData
               
       // Perform HTTP Request
       let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
           // Check for Error
           if let error = error {
               print("Error took place \(error)")
               return
           }
           let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
               if let responseJSON = responseJSON as? [String: Any] {
                   self.me = responseJSON
                   let response = self.stringify(json: responseJSON)
                   DispatchQueue.main.async {
                  //     self.outputText.text = response
                       print("from createUser: ", response)
                   }
               }
           }
           task.resume()
       }
   
    func login (_ user: [String: Any]) {

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
                   self.me = responseJSON
                   let response = self.stringify(json: responseJSON)
                   DispatchQueue.main.async {
                  //     self.outputText.text = response
                       print("from login: ", response)
                   }
               }
       }
       task.resume()
    }
   
    func logout () {
       
       self.disconnect()
       let url = self.setURLWithPath(path: "/users/logout")
       var request = self.setRequestTypeWithHeaders(method: "POST", url: url)
       let jsonData = try? JSONSerialization.data(withJSONObject: self.me, options: .prettyPrinted)
       self.me = [:]

       request.httpBody = jsonData
               
       let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
           if let error = error {
               print("Error took place \(error)")
               return
           }
           let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
               if let responseJSON = responseJSON as? [String: Any] {
                   let response = self.stringify(json: responseJSON)
                   DispatchQueue.main.async {
                 //      self.outputText.text = response
                       print("from logout: ", response)
                   }
               }
       }
       task.resume()
    }
   
   //handle socket events
   func socketConnect () {
       let socket = manager.defaultSocket
        socket.on("connect") {data, ack in
           print("socket connected")
           socket.emit("hello", "iOS client says: connected")
       }
       socket.on("idlePlayers") {data, ack in
           self.idlePlayers = data[0] as! [[String : Any]]
           self.convertPlayersToDisplayDescription()
           print("players in the room:", self.idlePlayers)
           DispatchQueue.main.async {
               self.playersTableView.reloadData()
           }
       }
       socket.on("letsPlay") {data, ack in
           print("thanks dude")
           self.gameOfferedBy(opponent: data[0] as! [String : Any])
       }
       socket.on("startingGame") {data, ack in
           print("starting game!!!", data[0])
           self.myOpponent = data[0] as! [String:Any]
       }
       socket.on("noGame") {data, ack in
           print("no game!!!")
       }
       socket.on("reply") {data, ack in
           print("msg from any:", data[0])

       }
       socket.connect()
   }
   //emit events
   func enterIdleUsersRoom () {
       let socket = manager.defaultSocket
       socket.emit("enterAsIdlePlayer", self.me)
   }
   func sendGameMove () {
       let socket = manager.defaultSocket
       socket.emit("play",[self.me, "hello from 11pro"])
   }
   func getIdleUsers () {
       let socket = manager.defaultSocket
       socket.emit("getIdlePlayers", self.me)
   }
   func offerGame (opponent:[String:Any]) {
       let socket = manager.defaultSocket
       socket.emit("offerGame", opponent)
   }
   func acceptGame (_ opponent:[String:Any]) {
       let socket = manager.defaultSocket
       socket.emit("gameAccepted", opponent)
   }
   func declineGame (_ opponent:[String:Any]) {
       let socket = manager.defaultSocket
       socket.emit("gameDeclined", opponent)
   }
   func disconnect () {
       let socket = manager.defaultSocket
       socket.emit("disconnect")
   }
                                           //Table funcs//
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.idlePlayers.count
   }
      
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell:UITableViewCell = self.playersTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
      cell.textLabel?.text = self.playersAtDispalyFormat[indexPath.row]
      
      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       print("row \(indexPath.row) picked")
       let pickedPlayer = self.idlePlayers[indexPath.row]
       self.offerGame(opponent: pickedPlayer)
   }
      
                                           //utility funcs//
   
   func stringify (json:[String: Any]) -> String {
       var convertedString:String = ""
       do {
           let data1 =  try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
           convertedString = String(data: data1, encoding: String.Encoding.utf8) ?? "Conversion error"
             } catch let myJSONError {
                 print("from stringify", myJSONError)
             }
       return convertedString
   }
   func setURLWithPath (path:String) -> URL {
       var components = URLComponents()
       components.scheme = scheme
       components.host = host
       components.port = port
       components.path = path
       return components.url!
   }
   func setRequestTypeWithHeaders (method:String, url:URL) -> URLRequest {
       var request = URLRequest(url: url)
       request.httpMethod = method
       request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       request.addValue("application/json", forHTTPHeaderField: "Accept")
       return request
   }
   
   
   func convertPlayersToDisplayDescription () {
       self.playersAtDispalyFormat = []
       for player in idlePlayers {
           let playerDisplayDescription = self.convertPlayerToDisplayDescription(player: player)
           playersAtDispalyFormat.append(playerDisplayDescription)
           print (playerDisplayDescription)
       }
   }
   
   func convertPlayerToDisplayDescription (player:[String:Any]) -> String {
       let userDetails = player["user"]!
       let displayDescription = (userDetails as! [String:Any])["userName"] as! String
       return displayDescription
   }
   
   func gameOfferedBy (opponent:[String:Any]) {
       let descrpitionString = self.convertPlayerToDisplayDescription(player: opponent)
       let optionMenu = UIAlertController(title: nil, message: "play with \(descrpitionString)?", preferredStyle: .actionSheet)
       let acceptAction = UIAlertAction(title: "Accept", style: .default) { action -> Void in
           print("\n\n accepted")
           self.acceptGame(opponent)
       }
       let declineAction = UIAlertAction(title: "Decline", style: .default) { action -> Void in
           print("\n\n declined")
           self.declineGame(opponent)
       }

       optionMenu.addAction(acceptAction)
       optionMenu.addAction(declineAction)

       self.present(optionMenu, animated: true, completion: nil)
   }
  
}




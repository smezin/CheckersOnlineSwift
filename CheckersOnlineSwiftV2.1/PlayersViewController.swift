//
//  PlayersViewController.swift
//
import UIKit
import Foundation
import SocketIO

class PlayersViewController: UIViewController, UIActionSheetDelegate {

    static let shared = PlayersViewController()
    
    @IBOutlet weak var playersTableView: UITableView!
    let cellReuseIdentifier = "PlayersTableCell"
    let scheme = "http"
    let port = 3000
    let host = "localhost"
    let defaults = UserDefaults.standard
    var me:[String: Any] = [:]
    var myOpponent:[String:Any] = [:]
    var idlePlayers:[[String:Any]] = []
    var allPlayersNames:[String] = []
    var playersAtDispalyFormat:[String] = []
    var isLoggedIn:Bool = false
    let nc = NotificationCenter.default
    
    static let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(false), .compress])
   
    override func viewDidLoad() {
       super.viewDidLoad()
       self.playersTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
       let nib = UINib(nibName: "PlayersTableViewCell",bundle: nil)
       self.playersTableView.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
       playersTableView.delegate = self
       playersTableView.dataSource = self
       socketConnect()
   }
   //tempies
    @IBAction func loginB(_ sender: Any) {
        let user: [String: Any] = ["userName": defaults.string(forKey: "userName")! as String,
                                   "password": defaults.string(forKey: "password")! as String]
        self.login(user)
    }
    @IBAction func conncetB(_ sender: Any) {
        self.connectRoom()
    }
    @IBAction func logoutB(_ sender: Any) {
        self.logout()
    }
    @IBAction func disconnectB(_ sender: Any) {
        self.disconnect()
    }
    @IBAction func newPlayerB(_ sender: Any) {
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let gameView  = storyBoard.instantiateViewController(withIdentifier: "GameViewID") as! GameViewController
        self.present(gameView, animated: true, completion: nil)
    }
    
   
   //
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
                   let response = self.stringify(json: responseJSON)
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
                   let response = self.stringify(json: responseJSON)
                    if (response.count < 10) {
                        PlayersViewController.shared.isLoggedIn = false
                        self.nc.post(name: .loginFailure, object: nil)
                    } else {
                        PlayersViewController.shared.isLoggedIn = true
                        self.nc.post(name: .loginSuccess, object: nil)
                    }
               }
        }
        task.resume()
    }
   
    func logout () {
       
       self.disconnect()
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
               if let responseJSON = responseJSON as? [String: Any] {
                   let response = self.stringify(json: responseJSON)
                   print("from logout: ", response)
               }
       }
       task.resume()
    }
   
    //handle socket events
    func socketConnect () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.on("connect") {data, ack in
           print("socket connected")
        }
        socket.on("idlePlayers") {data, ack in
           self.idlePlayers = data[0] as! [[String : Any]]
           self.convertPlayersToDisplayDescription()
           DispatchQueue.main.async {
               self.playersTableView.reloadData()
           }
        }
        socket.on("letsPlay") {data, ack in
            self.gameOfferedBy(opponent: data[0] as! [String : Any])
        }
        socket.on("startingGame") {data, ack in
            PlayersViewController.shared.myOpponent = data[0] as! [String:Any]
            GameModel.isMyTurn = true
            self.goToGameView()
            
        }
        socket.on("noGame") {data, ack in
            print("no game!!!")
        }
        socket.on("gameMove") {data, ack in
            GameModel.isMyTurn = true
            let board:[BoardSquare] = self.boardifyJson(jsonBoard: data[0] as! [String:Any])
            GameModel.board = board
            PlayersViewController.shared.nc.post(name: .boardReceived, object: nil)
            
        }
        socket.connect()
    }
    

    //emit events
    func connectRoom () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("enterAsIdlePlayer", PlayersViewController.shared.me)
    }
    func sendGameMove () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("play",[PlayersViewController.shared.me, "hello from 11pro"])
    }
    func getIdleUsers () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("getIdlePlayers", PlayersViewController.shared.me)
    }
    func offerGame (opponent:[String:Any]) {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("offerGame", opponent)
    }
    func acceptGame (_ opponent:[String:Any]) {
        let socket = PlayersViewController.manager.defaultSocket
        PlayersViewController.shared.myOpponent = opponent
        socket.emit("gameAccepted", opponent)
        self.goToGameView()
    }
    func declineGame (_ opponent:[String:Any]) {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("gameDeclined", opponent)
    }
    func disconnect () {
        let socket = PlayersViewController.manager.defaultSocket
        print("disconnected")
        socket.emit("disconnect")
    }
    func sendBoard (_ board:[String:Any]) {
        let socket = PlayersViewController.manager.defaultSocket
        print("from sendBoard", socket)
        socket.emit("boardData", PlayersViewController.shared.myOpponent, board)
    }

                                           //utility funcs//
       
    func stringify (json:[String: Any]) -> String {
       var convertedString:String = ""
       do {
           let data =  try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
           convertedString = String(data: data, encoding: String.Encoding.utf8) ?? "Conversion error"
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
       }
    }
    
    func createPlayersNamesList (allPlayers:[[String:Any]]) -> [String] {
        var namesList:[String] = []
        for player in allPlayers {
            let name = self.convertPlayerToDisplayDescription(player: player)
            namesList.append(name)
        }
        return namesList
    }
   
    func convertPlayerToDisplayDescription (player:[String:Any]) -> String {
       let userDetails = player["user"] ?? player
       let displayDescription = (userDetails as! [String:Any])["userName"] as! String
       return displayDescription
    }
   
    func gameOfferedBy (opponent:[String:Any]) {
       let descrpitionString = self.convertPlayerToDisplayDescription(player: opponent)
       let optionMenu = UIAlertController(title: nil, message: "play with \(descrpitionString)?", preferredStyle: .actionSheet)
       let acceptAction = UIAlertAction(title: "Accept", style: .default) { action -> Void in
           self.acceptGame(opponent)
       }
       let declineAction = UIAlertAction(title: "Decline", style: .default) { action -> Void in
           self.declineGame(opponent)
       }

       optionMenu.addAction(acceptAction)
       optionMenu.addAction(declineAction)

       self.present(optionMenu, animated: true, completion: nil)
    }
    
    func goToGameView () {
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let gameView  = storyBoard.instantiateViewController(withIdentifier: "GameViewID") as! GameViewController
        self.present(gameView, animated: true, completion: nil)
    }
    
    func boardifyJson (jsonBoard:[String:Any]) -> [BoardSquare] {
        var board:[BoardSquare] = Array()
        for index:Int in 0 ..< 64 {
            let strIndex = String(index)
            let currentSquare:[String:Any] = jsonBoard[strIndex] as! [String : Any]
            if currentSquare["type"] as! String == "boardSquare" {
                board.append(BoardSquare())
            } else if currentSquare["type"] as! String == "piece" {
                let isMyPiece:Bool = currentSquare["isMyPiece"] as! Bool
                let forwardIs:Piece.ForwardIs = currentSquare["forwardIs"] as! String == "up" ? .up:.down
                let pieceType:Piece.PieceType = self.convertStringToPieceType(piece: currentSquare["pieceType"] as! String)
                board.append(Piece(isMyPiece: isMyPiece, pieceType: pieceType, forwardIs: forwardIs))
            }
        }
        return board
    }
    
    private func convertStringToPieceType (piece:String) -> Piece.PieceType {
        var pieceType:Piece.PieceType? = nil
        switch piece {
        case "blackPawn":
            pieceType = .black_pawn
        case "blackQueen":
            pieceType = .black_queen
        case "whitePawn":
            pieceType = .white_pawn
        case "whiteQueen":
            pieceType = .white_queen
        default:
            pieceType = nil
        }
        return pieceType!
    }
  
}

extension PlayersViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.idlePlayers.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PlayersTableViewCell = self.playersTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as! PlayersTableViewCell
        cell.playerName?.text = self.playersAtDispalyFormat[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pickedPlayer = self.idlePlayers[indexPath.row]
        self.offerGame(opponent: pickedPlayer)
    }
}

extension PlayersViewController:SettingsData {
    static var settings: GameSettings = GameSettings()
}
extension Notification.Name {
    static let loginSuccess = Notification.Name("loginSuccess")
    static let loginFailure = Notification.Name("loginFailure")
}


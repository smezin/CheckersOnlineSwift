
import UIKit
import Foundation
import SocketIO


class PlayersViewController: UIViewController, UIActionSheetDelegate {
    
    static let shared = PlayersViewController()
    @IBOutlet weak var enterChooseButton: UIButton!
    @IBOutlet weak var playersTableView: UITableView!
    let cellReuseIdentifier = "PlayersTableCell"
    let scheme = "http"
    let port = 3000
    let host = "127.0.0.1"
    //let host = "134.122.110.154"
    let defaults = UserDefaults.standard
    var me:[String: Any] = [:]
    var myOpponent:[String:Any] = [:]
    var idlePlayers:[[String:Any]] = []
    var allPlayersNames:[String] = []
    var playersAtDispalyFormat:[String] = []
    var isLoggedIn:Bool = false
    var isInRoom = false
    let nc = NotificationCenter.default
    
    static let manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:3000")!, config: [.log(false), .compress])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playersTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        let nib = UINib(nibName: "PlayersTableViewCell", bundle: nil)
        self.playersTableView.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
        playersTableView.delegate = self
        playersTableView.dataSource = self
        playersTableView.backgroundView = UIImageView(image: UIImage(named: "tableview_background.jpg"))
        self.addObservers()
        self.socketConnect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getIdlePlayers()
        self.playersTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disconnect()
    }
    
    private func addObservers () {
        nc.addObserver(self, selector: #selector(connectRoom), name: .loginSuccess, object: nil)
        nc.addObserver(self, selector: #selector(updateEnterChooseButton), name: .enteredRoom, object: nil)
        nc.addObserver(self, selector: #selector(opponentLost(_:)), name: .iWon, object: nil)
        nc.addObserver(self, selector: #selector(opponentWon(_:)), name: .iLost, object: nil)
        nc.addObserver(self, selector: #selector(appExit), name: .appExit, object: nil)
    }
    @objc func updateEnterChooseButton () {
        if self.isInRoom {
            self.enterChooseButton.setImage(UIImage(named: "choose_player"), for: .normal)
        } else {
            self.enterChooseButton.setImage(UIImage(named: "enter_room"), for: .normal)
        }
    }
    @objc func appExit () {
        self.disconnect()
    }
    
    @IBAction func enterRoomButton(_ sender: Any) {
        self.connectRoom()
        self.updateEnterChooseButton()
    }
    @IBAction func logoutButton(_ sender: Any) {
        self.logout()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func leaveRoomButton(_ sender: Any) {
        self.disconnect()
        self.updateEnterChooseButton()
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
    

    func goToGamesView (isFirstTurnMine:Bool, _ gameID:String) {
        let opponentName:String = self.convertPlayerToDisplayDescription(player: self.myOpponent)
        let gameView = GameViewController()
        gameView.isMyTurn = isFirstTurnMine
        gameView.myOpponent = self.myOpponent
        gameView.gameID = gameID
        let info = [opponentName:gameView]
        let vc = ActiveGamesViewController()
        ActiveGamesViewController.activeGames.append(info)
        vc.modalPresentationStyle = .fullScreen
        performSegue(withIdentifier: "gotoActiveGames", sender: nil)
    }
    
}
//Handle sockets events listen and emit
//Listen
extension PlayersViewController {
    func socketConnect () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        socket.on("idlePlayers") {data, ack in
            if (!data.isEmpty) {
                self.idlePlayers = data[0] as! [[String : Any]]
                self.convertPlayersToDisplayDescription()
                DispatchQueue.main.async {
                    self.playersTableView.reloadData()
                }
            }
        }
        socket.on("letsPlay") {data, ack in
            if let otherPlayer = data[0] as? [String : Any] {
                self.gameOfferedBy(opponent: otherPlayer)
            }
        }
        socket.on("startingGame") {data, ack in
            self.myOpponent = data[0] as! [String:Any]
            let gameID = data[1] as! String
            self.goToGamesView(isFirstTurnMine: false, gameID)
        }
        socket.on("noGame") {data, ack in
            let opponentName:String = self.convertPlayerToDisplayDescription(player: data[0] as! [String : Any])
            self.showAlertMessage("\(opponentName) declined the offer", "Choose another player")
        }
        socket.on("gameMove") {data, ack in
            let board:[BoardSquare] = self.boardifyJson(jsonBoard: data[0] as! [String:Any])
            let gameID:String = data[1] as! String
            PlayersViewController.shared.nc.post(name: .boardReceived, object: nil, userInfo: ["board":board, "gameID":gameID])
        }
        socket.on("enteredRoom") {data, ack in
            self.isInRoom = true
            self.updateEnterChooseButton()
        }
        socket.on("leftRoom") {data, ack in
            self.isInRoom = false
            self.updateEnterChooseButton()
        }
        socket.on("youLost") {data, ack in
            let gameID:String = data[0] as! String
            PlayersViewController.shared.nc.post(name: .showLostMessage, object: nil, userInfo: ["gameID":gameID])
        }
        socket.on("youWon") {data, ack in
            let gameID:String = data[0] as! String
            PlayersViewController.shared.nc.post(name: .showWinMessage, object: nil, userInfo: ["gameID":gameID])
        }
        socket.connect()
    }
    
    //Emit events
    @objc func connectRoom () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("enterAsIdlePlayer", PlayersViewController.shared.me)
    }
    func getIdlePlayers () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("getIdlePlayers", PlayersViewController.shared.me)
    }
    func offerGame (opponent:[String:Any]) {
        if self.convertPlayerToDisplayDescription(player: opponent)  == self.convertPlayerToDisplayDescription(player: PlayersViewController.shared.me) {
            self.showAlertMessage("Don't play with yourself", "Not here anyway")
            return
        }
        if !self.isInRoom {
            self.showAlertMessage("You are not in the room", "Please enter room in order to pick opponent")
            return
        }
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("offerGame", opponent)
    }
    func acceptGame (_ opponent:[String:Any]) {
        let socket = PlayersViewController.manager.defaultSocket
        self.myOpponent = opponent
        let gameID = UUID()
        socket.emit("gameAccepted", opponent, gameID.uuidString)
        self.goToGamesView(isFirstTurnMine: true, gameID.uuidString)
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
    func sendBoard (_ board:[String:Any], opponent:[String:Any], _ gameID:String) {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("boardData", opponent, board, gameID)
        PlayersViewController.shared.nc.post(name: .boardSent, object: nil, userInfo: ["gameID":gameID])
    }
    @objc func opponentLost (_ notification:NSNotification) {
        let socket = PlayersViewController.manager.defaultSocket
        let gameID:String = notification.userInfo?["gameID"] as! String
        socket.emit("iWon", self.myOpponent, gameID)
    }
    @objc func opponentWon (_ notification:NSNotification) {
        let socket = PlayersViewController.manager.defaultSocket
        let gameID:String = notification.userInfo?["gameID"] as! String
        socket.emit("iLost", self.myOpponent, gameID)
    }
}
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
            if (responseJSON as? [String: Any]) != nil {
                self.nc.post(name: .logout, object: nil)
            }
        }
        task.resume()
    }
}

//Handle players tableView
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//Handle alerts
extension PlayersViewController {
    func showAlertMessage (_ title:String, _ message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

//handle JSONs and strings
extension PlayersViewController {
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
//Handle URL andrequests
extension PlayersViewController {
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
}

extension PlayersViewController:SettingsData {
    static var settings: GameSettings = GameSettings()
}



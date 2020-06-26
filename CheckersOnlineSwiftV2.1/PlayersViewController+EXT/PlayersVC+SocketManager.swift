
import UIKit
import SocketIO

//Handle sockets events listen and emit
//Listen
extension PlayersViewController {
    static let manager = SocketManager(socketURL: URL(string: UserDefaults.standard.object(forKey: "serverURLString") as! String)!, config: [.log(false), .compress])
    
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
            self.gotoGamesView(isFirstTurnMine: false, gameID)
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
            PlayersViewController.shared.nc.post(name: .playerLost, object: nil, userInfo: ["gameID":gameID])
        }
        socket.on("youWon") {data, ack in
            let gameID:String = data[0] as! String
            PlayersViewController.shared.nc.post(name: .playerWon, object: nil, userInfo: ["gameID":gameID])
        }
        socket.on("disconnect") {data, ack in
            self.exitRoom()
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
        self.gotoGamesView(isFirstTurnMine: true, gameID.uuidString)
    }
    func declineGame (_ opponent:[String:Any]) {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("gameDeclined", opponent)
    }
    func exitRoom () {
        let socket = PlayersViewController.manager.defaultSocket
        socket.emit("exitRoom")
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

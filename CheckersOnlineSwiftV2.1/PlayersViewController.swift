
import UIKit
import Foundation
import SocketIO

class PlayersViewController: UIViewController, UIActionSheetDelegate, SettingsData {
    
    static let shared = PlayersViewController()
    static var settings: GameSettings = GameSettings()
    @IBOutlet weak var enterChooseButton: UIButton!
    @IBOutlet weak var playersTableView: UITableView!
    let cellReuseIdentifier = "PlayersTableCell"
    let defaults = UserDefaults.standard
    var me:[String: Any] = [:]
    var myOpponent:[String:Any] = [:]
    var idlePlayers:[[String:Any]] = []
    var allPlayersNames:[String] = []
    var playersAtDispalyFormat:[String] = []
    var isLoggedIn:Bool = false
    var isInRoom = false
    var serverAddress:URL? = nil
    let nc = NotificationCenter.default
 
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
        self.exitRoom()
    }
 
    private func addObservers () {
        nc.addObserver(self, selector: #selector(connectRoom), name: .loginSuccess, object: nil)
        nc.addObserver(self, selector: #selector(updateEnterChooseButton), name: .enteredRoom, object: nil)
        nc.addObserver(self, selector: #selector(opponentLost(_:)), name: .iWon, object: nil)
        nc.addObserver(self, selector: #selector(opponentWon(_:)), name: .playerResigned, object: nil)
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
        self.exitRoom()
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
        self.exitRoom()
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
    

    func gotoGamesView (isFirstTurnMine:Bool, _ gameID:String) {
        let opponentName:String = self.convertPlayerToDisplayDescription(player: self.myOpponent)
        let gameView = GameViewController()
        gameView.isMyTurn = isFirstTurnMine
        gameView.myOpponent = self.myOpponent
        gameView.gameID = gameID
        let info:[String:Any] = ["gameID":gameID, "gameView":gameView, "opponentName":opponentName]
        ActiveGamesViewController.activeGames.append(info)
        performSegue(withIdentifier: "gotoActiveGames", sender: "gotoGamesView")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender is String {
            let sender = sender as! String
            if sender == "gotoGamesView" {
                let destination = segue.destination as! ActiveGamesViewController
                destination.initGame = true
            }
        }
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
//Handle URL and requests
extension PlayersViewController {
    func setURLWithPath (path:String) -> URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = (defaults.object(forKey: "host") as! String)
        components.port = (defaults.object(forKey: "port") as! Int)
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




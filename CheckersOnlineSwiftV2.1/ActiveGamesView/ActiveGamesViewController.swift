

import UIKit

class ActiveGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let shared = ActiveGamesViewController()
  
    @IBOutlet weak var activeGamesTableView: UITableView!
    var initGame:Bool = false
    let cellReuseIdentifier = "ActiveGamesTableViewCell"
    let nc = NotificationCenter.default
    static var activeGames:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "ActiveGamesTableViewCell", bundle: nil)
        self.activeGamesTableView.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
        activeGamesTableView.delegate = self
        activeGamesTableView.dataSource = self
        activeGamesTableView.backgroundView = UIImageView(image: UIImage(named: "tableview_background_active.jpg"))
        nc.addObserver(self, selector: #selector(closeActiveGame(_:)), name: .closeActiveGame, object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initGame {
            initGame = false
            let gameInfo = ActiveGamesViewController.activeGames[ActiveGamesViewController.activeGames.count-1]
            let gameView = gameInfo["gameView"] as! GameViewController
            self.present(gameView, animated: true, completion: nil)
        }
    }
    @objc func closeActiveGame (_ notification:NSNotification) {
        let gameID = notification.userInfo?["gameID"] as! String
        for index in 0 ..< ActiveGamesViewController.activeGames.count {
            if ActiveGamesViewController.activeGames[index]["gameID"] as! String == gameID {
                ActiveGamesViewController.activeGames.remove(at: index)
                self.activeGamesTableView.reloadData()
                return
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ActiveGamesViewController.activeGames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let gameInfo = ActiveGamesViewController.activeGames[indexPath.row]
        let gameView = gameInfo["gameView"] as! GameViewController
        self.present(gameView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ActiveGamesTableViewCell
        let gameInfo = ActiveGamesViewController.activeGames[indexPath.row]
        let opponentName = gameInfo["opponentName"] as! String
        cell.gameNameLabel.text = opponentName
        
        return cell
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

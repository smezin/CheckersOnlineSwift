

import UIKit

class ActiveGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let shared = ActiveGamesViewController()
    @IBOutlet weak var activeGamesTableView: UITableView!
    let cellReuseIdentifier = "GamesTableViewCell"
    var activeGames:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("lines: \(activeGames.count)")
        print(activeGames[0])
        self.activeGamesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        activeGamesTableView.delegate = self
        activeGamesTableView.dataSource = self
        /*
         self.playersTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
         let nib = UINib(nibName: "PlayersTableViewCell", bundle: nil)
         self.playersTableView.register(nib, forCellReuseIdentifier: cellReuseIdentifier)
         playersTableView.delegate = self
         playersTableView.dataSource = self
         playersTableView.backgroundView = UIImageView(image: UIImage(named: "tableview_background.jpg"))
         */
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeGames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("selected \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        let gameView = Array(activeGames[indexPath.row].values)[0] as! GameViewController
        self.present(gameView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = Array(activeGames[indexPath.row].keys)[0]
        return cell
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

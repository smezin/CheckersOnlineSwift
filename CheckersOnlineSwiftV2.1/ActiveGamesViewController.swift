

import UIKit

class ActiveGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let shared = ActiveGamesViewController()
  
    @IBOutlet weak var activeGamesTableView: UITableView!
    let cellReuseIdentifier = "GamesTableViewCell"
    static var activeGames:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("lines: \(ActiveGamesViewController.activeGames.count)")
        print(ActiveGamesViewController.activeGames[0])
        self.activeGamesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        activeGamesTableView.delegate = self
        activeGamesTableView.dataSource = self
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ActiveGamesViewController.activeGames.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("selected \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        let gameView = Array(ActiveGamesViewController.activeGames[indexPath.row].values)[0] as! GameViewController
        self.present(gameView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = Array(ActiveGamesViewController.activeGames[indexPath.row].keys)[0]
        return cell
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

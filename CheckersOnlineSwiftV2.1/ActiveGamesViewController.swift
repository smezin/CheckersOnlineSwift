

import UIKit

class ActiveGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let shared = ActiveGamesViewController()
    @IBOutlet weak var activeGamesTable: UITableView!
    let cellReuseIdentifier = "GamesTableViewCell"
    var activeGames:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("lines: \(activeGames.count)")
        self.activeGamesTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        activeGamesTable.delegate = self
        activeGamesTable.dataSource = self
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

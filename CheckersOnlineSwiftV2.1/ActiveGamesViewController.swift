//
//  ActiveGamesViewController.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 17/06/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class ActiveGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var activeGamesTable: UITableView!
    let cellReuseIdentifier = "GamesTableViewCell"
    var gameView:GameViewController? = nil
    var activeGames:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activeGamesTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        activeGamesTable.delegate = self
        activeGamesTable.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
    
}

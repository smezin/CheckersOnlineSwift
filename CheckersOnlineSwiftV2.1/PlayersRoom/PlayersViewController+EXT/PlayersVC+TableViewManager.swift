import UIKit

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

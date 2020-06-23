import UIKit

extension GameViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isMyTurn {
            self.board = GameModel(self.gameID).processRequest(board: self.board, indexPath: indexPath, self.myOpponent)
            self.checkersBoardCollectionView.reloadData()
        }
    }
    
    @objc func updateBoard (_ notification:NSNotification) {
        let gameID = notification.userInfo?["gameID"] as! String
        if self.gameID != gameID {
            return
        }
        self.board = notification.userInfo?["board"] as! [BoardSquare]
        self.renderBoard()
        DispatchQueue.main.async {
            self.checkersBoardCollectionView.reloadData()
        }
        self.startMyTurn()
    }
    func startMyTurn () {
        self.isMyTurn = true
    }
    func updateFooter (_ footer:FooterView, gameOver:Bool = false) -> FooterView {
        if self.isMyTurn {
            footer.turnsImageView.image = UIImage(named: "your_turn")
        } else {
            footer.turnsImageView.image = UIImage(named: "opponents_turn")
        }
        return footer
    }
    
    @objc func endMyTurn (_ notification:NSNotification) {
        let gameID = notification.userInfo?["gameID"] as! String
        if self.gameID != gameID {
            return
        }
        self.isMyTurn = false
    }
}


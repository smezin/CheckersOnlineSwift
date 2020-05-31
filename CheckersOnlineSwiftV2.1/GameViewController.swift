
import UIKit
import Foundation

class GameViewController: UIViewController, GameData, SettingsData {
    
    static var settings: GameSettings = GameSettings()
    let imageViewsTag = 1000
    var checkersBoardCollectionView: UICollectionView!
    static var board:[BoardSquare] = Array()
    var isMyTurn:Bool = false
    let nc = NotificationCenter.default
    
    override func loadView() {
        super.loadView()
        nc.addObserver(self, selector: #selector(updateBoard), name: .boardReceived, object: nil)
        nc.addObserver(self, selector: #selector(endMyTurn), name: .boardSent, object: nil)
        nc.addObserver(self, selector: #selector(playerWon), name: .iWon, object: nil)
        nc.addObserver(self, selector: #selector(playerLost), name: .iLost, object: nil)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        
        //set board size constraints
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: -CGFloat(GameViewController.settings.topMarginConstraint)),
            self.view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: -CGFloat(GameViewController.settings.sideMarginConstraint)),
            self.view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: CGFloat(GameViewController.settings.sideMarginConstraint)),
        ])
        
        self.checkersBoardCollectionView = collectionView
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkersBoardCollectionView.dataSource = self
        self.checkersBoardCollectionView.delegate = self
        self.checkersBoardCollectionView.register(UINib.init(nibName: GameViewController.settings.headerViewId, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GameViewController.settings.headerViewId)
        self.checkersBoardCollectionView.register(UINib.init(nibName: GameViewController.settings.footerViewId, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: GameViewController.settings.footerViewId)
        self.checkersBoardCollectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        self.checkersBoardCollectionView.backgroundColor = self.view.backgroundColor
        self.checkersBoardCollectionView.alwaysBounceVertical = true
        
        GameViewController.board = GameModel().setBoardForNewGame(GameViewController.settings)
    }
    //Handle game end scenarios
    @objc func playerWon () {
        self.showAlertMessage("YOU WON!!!", "Opponent lost or left the game")
    }
    @objc func playerLost () {
        self.showAlertMessage("YOU LOST", "You'll get better. probably")
    }
    func showAlertMessage (_ title:String, _ message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in self.goToPlayersVC()}))
        if self.presentedViewController == nil {
            self.present(alert, animated: true)
        } else {
            return
        }
    }
    func goToPlayersVC () {
        let playersView = storyboard?.instantiateViewController(withIdentifier: "playersID") as! PlayersViewController
        self.present(playersView, animated: true, completion: nil)
    }
    //Handle rendering board according to settings
    func renderBoard () {
        if GameViewController.settings.playWhites && !self.amIWhite()! {
            self.flipColors()
        }
        else if !GameViewController.settings.playWhites && self.amIWhite()! {
            self.flipColors()
        }
        
        if GameViewController.settings.playBottom && !self.amIatButtom()! {
            self.flipBoard()
        }
        else if !GameViewController.settings.playBottom && self.amIatButtom()! {
            self.flipBoard()
        }
        GameModel.board = GameViewController.board
    }
    
    private func amIWhite () -> Bool? {
        for square in GameViewController.board {
            if square.isKind(of: Piece.self) {
                let piece = square as! Piece
                if piece.isMyPiece {
                    if piece.pieceType == .white_pawn || piece.pieceType == .white_queen {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return nil
    }
    private func amIatButtom () -> Bool? {
        for square in GameViewController.board {
            if square.isKind(of: Piece.self) {
                let piece = square as! Piece
                if piece.isMyPiece {
                    if piece.forwardIs == .up {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return nil
    }
    
    private func flipBoard () {
        let tempBoard = GameViewController.board
        for index:Int in 0 ..< 64 {
            GameViewController.board[index] = tempBoard[63 - index]
            if GameViewController.board[index].isKind(of: Piece.self) {
                let piece = GameViewController.board[index] as! Piece
                if piece.forwardIs == .up {
                    piece.forwardIs = .down
                }
                else if piece.forwardIs == .down {
                    piece.forwardIs = .up
                }
            }
        }
    }
    private func flipColors () {
        for square in GameViewController.board {
            if square.isKind(of: Piece.self) {
                let piece = square as! Piece
                switch piece.pieceType {
                case .white_pawn:
                    piece.pieceType = .black_pawn
                case .white_queen:
                    piece.pieceType = .black_queen
                case .black_pawn:
                    piece.pieceType = .white_pawn
                case .black_queen:
                    piece.pieceType = .white_queen
                case .none:
                    print("render error")
                }
            }
        }
    }
}

//Handling data source
extension GameViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 64
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        let cellFrame = CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: cell.bounds.size.height)
        cell.backgroundView = getCellBackgroundView(index: indexPath.row)
        
        //animate pick
        if let cellImageView = getCellImageView(indexPath.row, cellFrame) {
            cell.addSubview(cellImageView)
            if GameModel.board[indexPath.row].isPicked {
                cellImageView.center.y -= CGFloat(GameViewController.settings.bounceHeight)
                UIImageView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                    cellImageView.center.y += CGFloat(GameViewController.settings.bounceHeight)
                }) 
            }
        } else {
            //remove subview that might have from reusing
            let subViews = cell.subviews
            for subview in subViews {
                if subview.tag == imageViewsTag {
                    subview.removeFromSuperview()
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind.isEqual(UICollectionView.elementKindSectionHeader) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GameViewController.settings.headerViewId, for: indexPath) as! HeaderView
            header.backgroundColor = self.view.backgroundColor
            return header
        } else if kind.isEqual(UICollectionView.elementKindSectionFooter) {
            var footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GameViewController.settings.footerViewId, for: indexPath) as! FooterView
            footer.backgroundColor = self.view.backgroundColor
            DispatchQueue.main.async {
                footer = self.updateFooter(footer)
            }
            return footer
        }
        else {
            return UICollectionReusableView()
        }
    }
    
    func getCellImageView (_ index:Int, _ cellFrame:CGRect) -> UIImageView? {
        let boardSquare:BoardSquare = GameViewController.board[index]
        var image = UIImage()
        var imageView = UIImageView()
        let piece:Piece? = boardSquare as? Piece
        if piece != nil {
            image = getImageByPieceType(piece: piece)
            imageView = UIImageView(image: image)
        }
        else if boardSquare.isOnPath && GameViewController.settings.showPaths {
            image = UIImage(named: GameViewController.settings.pathMarkImageName)!
            imageView = UIImageView(image: image)
        } else {
            return nil
        }
        imageView.frame = cellFrame
        imageView.tag = imageViewsTag
        return imageView
       
    }
    func getCellBackgroundView (index:Int) -> UIImageView{
        
        var cellImageView:UIImageView
        if (((index / 8) % 2) == 0) {
            if ((index % 2) == 0) {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.lightSquareImageName))
            } else {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.darkSquareImageName))
            }
        } else {
            if ((index % 2) == 1) {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.lightSquareImageName))
            } else {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.darkSquareImageName))
            }
        }
        return cellImageView
    }
    
    func getImageByPieceType (piece:Piece?) -> UIImage
    {
        if piece?.pieceType == nil {
            //remove from view
        }
        var image:UIImage
        switch piece?.pieceType {
        case .white_pawn:
            image = UIImage(named: GameViewController.settings.whitePawnImage)!
        case .black_pawn:
            image = UIImage(named: GameViewController.settings.blackPawnImage)!
        case .white_queen:
            image = UIImage(named: GameViewController.settings.whiteQueenImage)!
        case .black_queen:
            image = UIImage(named: GameViewController.settings.blackQueenImage)!
        default:
            image = UIImage()
        }
        return image
    }
}

extension GameViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        GameViewController.board = GameModel().processRequest(board: GameViewController.board, indexPath: indexPath)
        self.checkersBoardCollectionView.reloadData()
    }

    @objc func updateBoard () {
        GameViewController.board = GameModel.board
        self.renderBoard()
        DispatchQueue.main.async {
            self.checkersBoardCollectionView.reloadData()
        }
        self.startMyTurn()
    }
    func updateFooter (_ footer:FooterView, gameOver:Bool = false) -> FooterView {
        if self.isMyTurn {
            footer.turnsImageView.image = UIImage(named: "your_turn")
        } else {
            footer.turnsImageView.image = UIImage(named: "opponents_turn")
        }
        return footer
    }
  
    func startMyTurn () {
        self.isMyTurn = true
    }
    @objc func endMyTurn () {
        self.isMyTurn = false
    }
}

extension GameViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSideSize = min(collectionView.bounds.width, collectionView.bounds.height)/8
        return CGSize(width: cellSideSize, height: cellSideSize)

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    //header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: GameViewController.settings.headerHeight)
    }
    //footer
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: GameViewController.settings.footerHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
}

    




import UIKit
import Foundation
import AVFoundation

class GameViewController: UIViewController, SettingsData, GameData {
    
    static var settings: GameSettings = GameSettings()
    let imageViewsTag = 1000
    var checkersBoardCollectionView: UICollectionView!
    var board:[BoardSquare] = Array()
    var myOpponent:[String:Any] = [:]
    var isMyTurn:Bool = false
    var gameID:String = ""
    let nc = NotificationCenter.default
    let defaults = UserDefaults.standard
    
    override func loadView() {
        super.loadView()
        self.addObservers()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        self.view.backgroundColor = UIColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1)
        
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
        self.loadSettings()
        self.board = GameModel(self.gameID).setBoardForNewGame(GameViewController.settings)
    }
    func addObservers () {
        nc.addObserver(self, selector: #selector(updateBoard(_:)), name: .boardReceived, object: nil)
        nc.addObserver(self, selector: #selector(makeTurnPassSound), name: .boardReceived, object: nil)
        nc.addObserver(self, selector: #selector(endMyTurn(_:)), name: .boardSent, object: nil)
        nc.addObserver(self, selector: #selector(playerWon(_:)), name: .playerWon, object: nil)
        nc.addObserver(self, selector: #selector(playerLost(_:)), name: .playerLost, object: nil)
        nc.addObserver(self, selector: #selector(playerLost(_:)), name: .playerResigned, object: nil)
        nc.addObserver(self, selector: #selector(makeMoveSound), name: .makeMoveSound, object: nil)
        nc.addObserver(self, selector: #selector(makeMoveSound), name: .makePickSound, object: nil)
    }
    func loadSettings () {
        GameViewController.settings.playBottom = defaults.bool(forKey: "playBottom")
        GameViewController.settings.playWhites = defaults.bool(forKey: "playWhites")
        GameViewController.settings.showPaths = defaults.bool(forKey: "showPaths")
        GameViewController.settings.soundOn = defaults.bool(forKey: "soundOn")
    }
    //make sounds
    @objc func makeMoveSound () {
        if GameViewController.settings.soundOn {
            AudioServicesPlaySystemSound(GameViewController.settings.moveSoundID)
        }
    }
    @objc func makePickSound () {
        if GameViewController.settings.soundOn {
            AudioServicesPlaySystemSound(GameViewController.settings.pickSoundID)
        }
    }
    @objc func makeTurnPassSound () {
        if GameViewController.settings.soundOn {
            AudioServicesPlaySystemSound(GameViewController.settings.BoardReceivedSoundID)
        }
    }
    
    //Handle game end scenarios
    @objc func playerWon (_ notification:NSNotification) {
        let gameID = notification.userInfo?["gameID"] as! String
        if self.gameID != gameID {
            return
        }
        nc.post(name: .closeActiveGame, object: nil, userInfo: ["gameID":gameID])
        self.showAlertMessage("YOU WON!!!", "Opponent lost or left the game")
    }
    @objc func playerLost (_ notification:NSNotification) {
        let gameID = notification.userInfo?["gameID"] as! String
        if self.gameID != gameID {
            return
        }
        nc.post(name: .closeActiveGame, object: nil, userInfo: ["gameID":gameID])
        self.showAlertMessage("YOU LOST", "You'll get better. probably")
    }
    func showAlertMessage (_ title:String, _ message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in self.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true)
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
    }
    
    private func amIWhite () -> Bool? {
        for square in self.board {
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
        for square in self.board {
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
        let tempBoard = self.board
        for index:Int in 0 ..< 64 {
            self.board[index] = tempBoard[63 - index]
            if self.board[index].isKind(of: Piece.self) {
                let piece = self.board[index] as! Piece
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
        for square in self.board {
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


//
//  ViewController.swift
//  CheckersOnlineSwiftV2.1

import UIKit

class GameViewController: UIViewController, GameData, SettingsData {
    
    static var settings: GameSettings = GameSettings()
    let imageViewsTag = 1000
    var checkersBoardCollectionView: UICollectionView!
    static var board:[Piece?] = Array(repeating: Piece(isMyPiece: false, pieceType: nil), count: 64)
    
    override func loadView() {
        super.loadView()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(collectionView)
        let settings = GameSettings()
        
        //set board size constraints
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: -CGFloat(settings.topMarginConstraint)),
            self.view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: -CGFloat(settings.sideMarginConstraint)),
            self.view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: CGFloat(settings.sideMarginConstraint)),
        ])
        
        self.checkersBoardCollectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkersBoardCollectionView.dataSource = self
        self.checkersBoardCollectionView.delegate = self
        self.checkersBoardCollectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        self.checkersBoardCollectionView.backgroundColor = self.view.backgroundColor
        self.checkersBoardCollectionView.alwaysBounceVertical = true
        GameViewController.self.board = GameModel().setBoardForNewGame(GameViewController.self.board, GameViewController.settings)
    }
} //end of class

extension GameViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 64
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        let cellFrame = CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: cell.bounds.size.height)
        
        cell.backgroundColor = getCellBackgroundColor(index: indexPath.row)
        if getCellImageView(indexPath.row, cellFrame) != nil {
            cell.addSubview(getCellImageView(indexPath.row, cellFrame)!)
        } else {
            let subViews = cell.subviews
            for subview in subViews {
                if subview.tag == imageViewsTag {
                    subview.removeFromSuperview()
                }
            }
        }
        return cell
    }
   
    func getCellImageView (_ index:Int, _ cellFrame:CGRect) -> UIImageView? {

        let piece:Piece = GameViewController.board[index]!
        var image = UIImage()
        var imageView = UIImageView()
        if piece.pieceType != nil {
            image = getImageByPieceType(piece: piece)
            imageView = UIImageView(image: image)
        }
        else if piece.isOnPath && GameViewController.settings.showPaths {
            image = UIImage(named: "path_mark")!
            imageView = UIImageView(image: image)
        } else {
            return nil
        }
        imageView.frame = cellFrame
        imageView.tag = imageViewsTag
        return imageView
       
    }
    func getCellBackgroundColor (index:Int) -> UIColor{
        
        var cellColor:UIColor
        if (((index / 8) % 2) == 0) {
            if ((index % 2) == 0) {
                cellColor = GameViewController.settings.colorOne
            } else {
                cellColor = GameViewController.settings.colorTwo
            }
        } else {
            if ((index % 2) == 1) {
                cellColor = GameViewController.settings.colorOne
            } else {
                cellColor = GameViewController.settings.colorTwo
            }
        }
        return cellColor
    }
    
    func getImageByPieceType (piece:Piece?) -> UIImage
    {
        if piece?.pieceType == nil {
            //remove from view
        }
        var image:UIImage
        switch piece?.pieceType {
        case .white_pawn:
            image = UIImage(named: "white_pawn")!
        case .black_pawn:
            image = UIImage(named: "black_pawn")!
        case .white_queen:
            image = UIImage(named: "white_Queen")!
        case .black_queen:
            image = UIImage(named: "black_queen")!
        default:
            image = UIImage()
        }
        return image
    }
}

extension GameViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Picked indexPath=",indexPath.row)
        
        GameViewController.board = GameModel().processRequest(board: GameViewController.board, indexPath: indexPath)

        self.checkersBoardCollectionView.reloadData()
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
}

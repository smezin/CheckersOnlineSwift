//
//  ViewController.swift
//  CheckersOnlineSwiftV2.1

import UIKit

class GameViewController: UIViewController, GameData, SettingsData {
    
    static var settings: GameSettings = GameSettings()
    let imageViewsTag = 1000
    let darkSquareImageName = "wood_dark"
    let lightSquareImageName = "wood_light"
    let pathMarkImageName = "path_mark"
    let whitePawnImage = "white_pawn"
    let blackPawnImage = "black_pawn"
    let whiteQueenImage = "white_queen"
    let blackQueenImage = "black_queen"
    var checkersBoardCollectionView: UICollectionView!
    static var board:[BoardSquare] = Array()
    
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
        GameViewController.board = GameModel().setBoardForNewGame(GameViewController.settings)
    }
} //end of class

//Extentions

extension GameViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 64
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        let cellFrame = CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: cell.bounds.size.height)
        
        cell.backgroundView = getCellBackgroundView(index: indexPath.row)
        
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

        let boardSquare:BoardSquare = GameViewController.board[index]
        var image = UIImage()
        var imageView = UIImageView()
        let piece:Piece? = boardSquare as? Piece
        if piece != nil {
            image = getImageByPieceType(piece: piece)
            imageView = UIImageView(image: image)
        }
        else if boardSquare.isOnPath && GameViewController.settings.showPaths {
            image = UIImage(named: pathMarkImageName)!
            imageView = UIImageView(image: image)
        } else {
            return nil
        }
        imageView.frame = cellFrame
        imageView.tag = imageViewsTag
        return imageView
       
    }
    func getCellBackgroundView (index:Int) -> UIImageView{
        
        var cellView:UIImageView
        if (((index / 8) % 2) == 0) {
            if ((index % 2) == 0) {
                cellView = UIImageView(image: UIImage(named: lightSquareImageName))
            } else {
                cellView = UIImageView(image: UIImage(named: darkSquareImageName))
            }
        } else {
            if ((index % 2) == 1) {
                cellView = UIImageView(image: UIImage(named: lightSquareImageName))
            } else {
                cellView = UIImageView(image: UIImage(named: darkSquareImageName))
            }
        }
        return cellView
    }
    
    func getImageByPieceType (piece:Piece?) -> UIImage
    {
        if piece?.pieceType == nil {
            //remove from view
        }
        var image:UIImage
        switch piece?.pieceType {
        case .white_pawn:
            image = UIImage(named: whitePawnImage)!
        case .black_pawn:
            image = UIImage(named: blackPawnImage)!
        case .white_queen:
            image = UIImage(named: whiteQueenImage)!
        case .black_queen:
            image = UIImage(named: blackQueenImage)!
        default:
            image = UIImage()
        }
        return image
    }
    
    //
    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
      // 1
      switch kind {
      // 2
      case UICollectionView.elementKindSectionHeader:
        // 3
        guard
          let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerView",
            for: indexPath) as? HeaderView
          else {
            fatalError("Invalid view type")
        }
        headerView.headerLabel.text = "test"
        return headerView
      default:
        // 4
        assert(false, "Invalid element type")
      }
    }
}

extension GameViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
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

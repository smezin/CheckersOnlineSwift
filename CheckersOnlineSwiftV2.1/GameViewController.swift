//
//  ViewController.swift
//  CheckersOnlineSwiftV2.1

import UIKit
import Foundation

class GameViewController: UIViewController, GameData, SettingsData {
    
    static var settings: GameSettings = GameSettings()
    let imageViewsTag = 1000
    var checkersBoardCollectionView: UICollectionView!
    static var board:[BoardSquare] = Array()
    let nc = NotificationCenter.default
    
    override func loadView() {
        super.loadView()

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        nc.addObserver(self, selector: #selector(reloadData), name: .boardReceived, object: nil)
        
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
        self.checkersBoardCollectionView.register(UINib.init(nibName: GameViewController.settings.headerViewId, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GameViewController.settings.headerViewId)
        self.checkersBoardCollectionView.register(UINib.init(nibName: GameViewController.settings.footerViewId, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: GameViewController.settings.footerViewId)
        self.checkersBoardCollectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        self.checkersBoardCollectionView.backgroundColor = self.view.backgroundColor
        self.checkersBoardCollectionView.alwaysBounceVertical = true
        
        GameViewController.board = GameModel().setBoardForNewGame(GameViewController.settings)
    }
    
}

//Extentions
extension Notification.Name {
    static let boardReceived = Notification.Name("boardReceived")
}
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
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GameViewController.settings.footerViewId, for: indexPath) as! FooterView
            footer.backgroundColor = self.view.backgroundColor
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
        print("regular reload 11")
        self.checkersBoardCollectionView.reloadData()
    }
    
    @objc func reloadData () {
        print("notification reloading 11")
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

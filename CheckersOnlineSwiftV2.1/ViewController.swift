//
//  ViewController.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameData {

    var checkersBoardCollectionView: UICollectionView!
    var settings: GameSettings!
    static var board:[Piece?] = Array(repeating: nil, count: 64)

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
        ViewController.self.board = GameModel().setBoardForNewGame(board: ViewController.self.board)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
        self.checkersBoardCollectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 64
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        let settings = GameSettings()
        
        //handle cells color
        if (((indexPath.row / 8) % 2) == 0) {
            if ((indexPath.row % 2) == 0) {
                cell.backgroundColor = settings.colorOne
            } else {
                cell.backgroundColor = settings.colorTwo
            }
        } else {
            if ((indexPath.row % 2) == 1) {
                cell.backgroundColor = settings.colorOne
            } else {
                cell.backgroundColor = settings.colorTwo
            }
        }
        //set piece? image
        if let piece:Piece = ViewController.self.board[indexPath.row] {
            let frame = CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: cell.bounds.size.height)
            piece.pieceView.frame = frame
            cell.addSubview(piece.pieceView)
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Picked indexPath=",indexPath.row)
        let gm:GameModel = GameModel.init()
        if (ViewController.board[indexPath.row] == nil){
            ViewController.board = gm.addPiece(board: ViewController.board, indexPath: indexPath)
        } else {
            print("found piece!")
          //  var piece:UIView = (ViewController.board[indexPath.row]?.pieceView)!
        }
        self.checkersBoardCollectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

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





//
//  ViewController.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var checkersBoardCollectionView: UICollectionView!
    weak var settings: GameSettings!

    var data: [Int] = Array(0..<64)

    override func loadView() {
        super.loadView()

        //print(settings!.soundOn)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
      
        
        self.view.addSubview(collectionView)
        let settings = GameSettings()
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
        self.checkersBoardCollectionView.backgroundColor = .white
        self.checkersBoardCollectionView.alwaysBounceVertical = true
    }
}

func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if (kind == UICollectionView.elementKindSectionFooter) {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartFooterCollectionReusableView", for: indexPath)
        // Customize footerView here
        footerView.backgroundColor = .blue
        return footerView
    } else if (kind == UICollectionView.elementKindSectionHeader) {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartHeaderCollectionReusableView", for: indexPath)
        // Customize headerView here
        headerView.backgroundColor = .yellow
        return headerView
    }
    fatalError()
}
extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        let data = self.data[indexPath.item]
        cell.textLabel.text = String(data)
        let settings = GameSettings()
        if (((indexPath.row / 8) % 2) == 0) {
            if ((indexPath.row % 2) == 0){
                cell.backgroundColor = settings.colorOne
            } else {
                cell.backgroundColor = settings.colorTwo
            }
        } else {
            if ((indexPath.row % 2) == 1){
                cell.backgroundColor = settings.colorOne
            } else {
                cell.backgroundColor = settings.colorTwo
            }
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath=",indexPath.row)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/8, height: collectionView.bounds.width/8)
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





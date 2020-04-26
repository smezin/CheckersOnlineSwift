//
//  GameModel.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 26/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class GameModel: NSObject {
    weak var checkersBoardCollectionView: UICollectionView!
    var board:[Piece.PieceType] = Array(repeating: Piece.PieceType.empty, count: 64) //get in a protocol
    
    
}

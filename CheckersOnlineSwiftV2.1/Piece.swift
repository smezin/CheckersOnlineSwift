//
//  Piece.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 26/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class Piece: NSObject {
    enum PieceType {
        case white_pawn
        case black_pawn
        case white_queen
        case black_queen
    }

    var pieceType:PieceType!
    var isOnPath:Bool = false
    var isMyPiece:Bool!
    var isPicked:Bool!
    
    init(_ isMyPiece:Bool, _ pieceType:PieceType?)
    {
     //   super.init()
        self.isMyPiece = isMyPiece
        self.pieceType = pieceType
        self.isPicked = false
        self.isOnPath = false
    }
    
}

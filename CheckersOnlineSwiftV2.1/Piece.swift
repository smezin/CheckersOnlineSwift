//
//  Piece.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 26/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class Piece: BoardSquare {
    enum PieceType {
        case white_pawn
        case black_pawn
        case white_queen
        case black_queen
    }
    enum ForwardIs {
        case up
        case down
    }

    var pieceType:PieceType?
    var isMyPiece:Bool?
    var forwardIs:ForwardIs?
    
    init(isMyPiece:Bool?, pieceType:PieceType?, forwardIs:ForwardIs?)
    {
        super.init()
        self.isMyPiece = isMyPiece
        self.pieceType = pieceType
        self.forwardIs = forwardIs
    }
    
}

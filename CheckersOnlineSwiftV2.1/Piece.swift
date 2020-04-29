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
    enum ForwardIs {
        case up
        case down
    }

    var pieceType:PieceType!
    var isOnPath:Bool = false
    var isMyPiece:Bool?
    var isPicked:Bool!
    var forwardIs:ForwardIs?
    
    init(isMyPiece:Bool?, pieceType:PieceType?, forwardIs:ForwardIs?)
    {
     //   super.init()
        self.isMyPiece = isMyPiece
        self.pieceType = pieceType
        self.forwardIs = forwardIs
        self.isPicked = false
        self.isOnPath = false
    }
    override convenience init()
    {
        self.init(isMyPiece: nil,pieceType: nil,forwardIs: nil)
    }
    
}

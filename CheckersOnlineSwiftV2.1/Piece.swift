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
    var pieceLocation:Int
    var pieceImage:UIImage!
    var pieceView:UIImageView!
    var pieceType:PieceType!
    var isOnPath:Bool!
    var isMyPiece:Bool!
    var isPicked:Bool!
    
    init(_ isMyPiece:Bool, _ pieceType:PieceType, _ pieceLocation:Int)
    {
        self.pieceLocation = pieceLocation
        self.isMyPiece = isMyPiece
        self.pieceType = pieceType
        self.isPicked = false
        self.isOnPath = false
        switch pieceType {
           case .white_pawn:
               self.pieceImage = UIImage(named: "white_pawn")
           case .black_pawn:
               self.pieceImage = UIImage(named: "black_pawn")
           default:
               break
           }
        self.pieceView = UIImageView(image: self.pieceImage)
    }
}

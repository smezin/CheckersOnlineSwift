//represents square with piece 
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
    enum Status {
        case resting
        case moving
    }

    var pieceType:PieceType!
    var isMyPiece:Bool!
    var forwardIs:ForwardIs!
    var status:Status = .resting
    
    init(isMyPiece:Bool?, pieceType:PieceType?, forwardIs:ForwardIs?)
    {
        super.init()
        self.isMyPiece = isMyPiece
        self.pieceType = pieceType
        self.forwardIs = forwardIs
    }
    
}

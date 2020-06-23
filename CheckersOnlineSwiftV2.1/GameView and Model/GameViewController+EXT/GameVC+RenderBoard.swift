import UIKit

extension GameViewController {
    func renderBoard () {
        if GameViewController.settings.playWhites && !self.amIWhite()! {
            self.flipColors()
        }
        else if !GameViewController.settings.playWhites && self.amIWhite()! {
            self.flipColors()
        }
        
        if GameViewController.settings.playBottom && !self.amIatButtom()! {
            self.flipBoard()
        }
        else if !GameViewController.settings.playBottom && self.amIatButtom()! {
            self.flipBoard()
        }
    }
    
    private func amIWhite () -> Bool? {
        for square in self.board {
            if square.isKind(of: Piece.self) {
                let piece = square as! Piece
                if piece.isMyPiece {
                    if piece.pieceType == .white_pawn || piece.pieceType == .white_queen {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return nil
    }
    private func amIatButtom () -> Bool? {
        for square in self.board {
            if square.isKind(of: Piece.self) {
                let piece = square as! Piece
                if piece.isMyPiece {
                    if piece.forwardIs == .up {
                        return true
                    } else {
                        return false
                    }
                }
            }
        }
        return nil
    }
    private func flipBoard () {
        let tempBoard = self.board
        for index:Int in 0 ..< 64 {
            self.board[index] = tempBoard[63 - index]
            if self.board[index].isKind(of: Piece.self) {
                let piece = self.board[index] as! Piece
                if piece.forwardIs == .up {
                    piece.forwardIs = .down
                }
                else if piece.forwardIs == .down {
                    piece.forwardIs = .up
                }
            }
        }
    }
    private func flipColors () {
        for square in self.board {
            if square.isKind(of: Piece.self) {
                let piece = square as! Piece
                switch piece.pieceType {
                case .white_pawn:
                    piece.pieceType = .black_pawn
                case .white_queen:
                    piece.pieceType = .black_queen
                case .black_pawn:
                    piece.pieceType = .white_pawn
                case .black_queen:
                    piece.pieceType = .white_queen
                case .none:
                    print("render error")
                }
            }
        }
    }
}

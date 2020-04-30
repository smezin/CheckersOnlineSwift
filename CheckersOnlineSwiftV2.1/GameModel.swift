//
//  GameModel.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 26/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

protocol GameData
{
    static var board:[BoardSquare] {get set}
}
enum Direction:Int, CaseIterable
{
    case upRight = -7
    case downRight = 9
    case upLeft = -9
    case downLeft = 7
}

class GameModel: NSObject, GameData {
    
    static var board:[BoardSquare] = Array()
    
    func setBoardForNewGame(_ settings:GameSettings) -> [BoardSquare] {
        
        var topPiecesColor:Piece.PieceType?
        var bottomPiecesColor:Piece.PieceType?
        var myPieceOnTop:Bool
        
        if settings.playBottom {
            myPieceOnTop = false
            if settings.playWhites {
                bottomPiecesColor = .white_pawn
                topPiecesColor = .black_pawn
            } else {
                bottomPiecesColor = .black_pawn
                topPiecesColor = .white_pawn
            }
        } else {
            myPieceOnTop = true
            if settings.playWhites {
                topPiecesColor = .white_pawn
                bottomPiecesColor = .black_pawn
            } else {
                topPiecesColor = .black_pawn
                bottomPiecesColor = .white_pawn
            }
        }
        setEmptyBoard()
        //real
        setTopPieces(isPieceMine: myPieceOnTop, pieceType: topPiecesColor!)
        setBottomPieces(isPieceMine: !myPieceOnTop, pieceType: bottomPiecesColor!)
        //testing
//        setTopPieces(isPieceMine: true, pieceType: topPiecesColor!)
//        setBottomPieces(isPieceMine: true, pieceType: bottomPiecesColor!)
        
        
        return GameModel.board
    }
    
    private func setEmptyBoard () {
        for _ in 0..<64 {
            GameModel.board.append(BoardSquare())
        }
    }
    
    private func setBottomPieces (isPieceMine:Bool, pieceType:Piece.PieceType) {
        for boardIndex:Int in 40..<64
        {
            if ((boardIndex / 8) == 5 || (boardIndex / 8) == 7) {
                if ((boardIndex % 2) == 0) {
                    GameModel.board[boardIndex] = Piece(isMyPiece: isPieceMine, pieceType: pieceType, forwardIs: .up)
                }
            }
            if ((boardIndex / 8) == 6) {
               if ((boardIndex % 2) == 1) {
                GameModel.board[boardIndex] = Piece(isMyPiece: isPieceMine, pieceType: pieceType, forwardIs: .up)
               }
           }
        }
    }
    
    private func setTopPieces (isPieceMine:Bool, pieceType:Piece.PieceType) {
        for boardIndex:Int in 0...24
        {
//            if ((boardIndex / 8) == 0 || (boardIndex / 8) == 2) {
//                if ((boardIndex % 2) == 1) {
//                    GameModel.board[boardIndex] = Piece(isMyPiece: isPieceMine, pieceType: pieceType, forwardIs: .down)
//                }
//            }
            if ((boardIndex / 8) == 1) {
               if ((boardIndex % 2) == 0) {
                GameModel.board[boardIndex] = Piece(isMyPiece: isPieceMine, pieceType: pieceType, forwardIs: .down)
               }
           }
        }
    }
        
    func processRequest(board:[BoardSquare], indexPath:IndexPath) -> [BoardSquare] {
        
        var didMove:Bool = false
        var isTurnEnded = false
        let index:Int = isPiecePicked()
        if index == -1 {
            if isMyPiece(index: indexPath.row) {
                GameModel.board[indexPath.row].isPicked = true
                findPathForPawnAt(index: indexPath.row)
            }
        }
        else {
            let piece:Piece? = GameModel.board[index] as? Piece
            if GameModel.board[indexPath.row].isOnPath {
                didMove = movePiece(from: index, to: indexPath.row)
                if piece?.status == .moving {
                    clearPaths()
                    findConsecutiveKillPathFor(index: indexPath.row)
                } else {
                    clearPaths()
                    clearPicks()
                }
            } else {
                clearPaths()
                clearPicks()
                if piece?.status == .moving {
                    piece?.status = .resting
                    isTurnEnded = true
                }
            }
            if (didMove && piece?.status == .resting) {
                isTurnEnded = true
            }
        }
        if isTurnEnded {
            print ("turn ended")
        }
        return GameModel.board
    }
    
    private func clearPaths () {
        for index:Int in 0..<64 {
            GameModel.board[index].isOnPath = false
        }
    }
    
    private func clearPicks () {
        for index:Int in 0..<64 {
            GameModel.board[index].isPicked = false
        }
    }
    
    private func findPathForPawnAt (index:Int) {
        let piece:Piece? = GameModel.board[index] as? Piece
        if piece == nil {
            return
        }
        if piece?.forwardIs == .up {
            findPathInDirections(index: index, .upLeft, .upRight)
        }
        if piece?.forwardIs == .down {
            findPathInDirections(index: index, .downLeft, .downRight)
           
        }
    }
    
    private func findPathInDirections (index:Int, _ directions:Direction...) {
        for direction in directions {
            if !isOutOfBoardBounds(from: index, to: index + direction.rawValue) {
                if let piece = GameModel.board[index + direction.rawValue] as? Piece {
                    if !piece.isMyPiece! {
                        if !isOutOfBoardBounds(from: index + direction.rawValue, to: index + 2*direction.rawValue) {
                                GameModel.board[index + 2*direction.rawValue].isOnPath = true
                        }
                    }
                } else {
                      GameModel.board[index + direction.rawValue].isOnPath = true
            //          findPathInDirections(index: index+direction.rawValue, direction)
                }
            }
        }
    }
    
    private func findConsecutiveKillPathFor (index:Int) {
        let piece:Piece = GameModel.board[index] as! Piece
        var isPathFound:Bool = false;
        for direction in Direction.allCases {
            if !isOutOfBoardBounds(from: index, to: index + direction.rawValue) && !isOutOfBoardBounds(from: index + direction.rawValue, to: index + 2*direction.rawValue) {
                if let piece = GameModel.board[index + direction.rawValue] as? Piece  {
                    if !piece.isMyPiece! {
                        if !(GameModel.board[index + 2*direction.rawValue] is Piece) {
                            GameModel.board[index + 2*direction.rawValue].isOnPath = true
                            isPathFound = true
                        }
                    }
                }
            }
        }
        if !isPathFound {
            piece.status = .resting
        }
    }
    
    private func isOutOfBoardBounds (from:Int, to:Int) -> Bool {
        if to < 0 || to > 63 {
            return true
        }
        if abs(from % 8 - to % 8) != 1 {
            return true
        }
        return false
    }
    
    private func isPiecePicked () -> Int {
        for index in 0..<64 {
            if GameModel.board[index].isPicked == true {
                return index
            }
        }
        return -1
    }
    
    private func isMyPiece (index:Int) -> Bool {
        let piece:Piece? = GameModel.board[index] as? Piece
        if piece != nil && piece!.isMyPiece! {
           return true
       }
        return false
    }
    
    private func movePiece (from:Int, to:Int) -> Bool
    {
        let piece:Piece? = GameModel.board[from] as? Piece
        if piece != nil && !piece!.isMyPiece! {
            return false
        }
        if GameModel.board[to] is Piece {
            return false
        }
        
        GameModel.board[to] = GameModel.board[from]
        GameModel.board[from] = BoardSquare()
        let reverseStep:Direction = getJumpedOverSquareDirection(from: from, to: to)!
        if GameModel.board[to + reverseStep.rawValue] as? Piece != nil {
            //if killed a piece
            piece?.status = .moving
            GameModel.board[to + reverseStep.rawValue] = BoardSquare()
        } else {
            piece?.status = .resting
            GameModel.board[from].isPicked = false
        }
        
        return true
    }
    private func getJumpedOverSquareDirection (from:Int, to:Int) ->Direction? {
        var direction:Direction?
        if from < to {
            if (to - from) % 7 == 0 {
                direction = .upRight
            } else if (to - from) % 9 == 0{
                direction = .upLeft
            }
        } else {
            if (to - from) % 7 == 0 {
                direction = .downLeft
            } else if (to - from) % 9 == 0{
                direction = .downRight
            }
        }
        return direction
    }
    
}

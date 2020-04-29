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
    static var board:[Piece] {get set}
}
enum Direction:Int, CaseIterable
{
    case upRight = -7
    case downRight = 9
    case upLeft = -9
    case downLeft = 7
}

class GameModel: NSObject, GameData {
    
   // static var board:[Piece?] = Array(repeating: Piece(isMyPiece: false, pieceType: nil), count: 64)
    static var board:[Piece] = Array()
    
    func setBoardForNewGame(_ board:[Piece], _ settings:GameSettings) -> [Piece] {
        var board = board
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
        for boardIndex:Int in 0..<64
        {
            board[boardIndex] = Piece(false, nil)
            //set bottom
            if ((boardIndex / 8) == 5 || (boardIndex / 8) == 7) {
                if ((boardIndex % 2) == 0) {
                    board[boardIndex] = Piece(!myPieceOnTop, bottomPiecesColor)
                }
            }
            if ((boardIndex / 8) == 6) {
               if ((boardIndex % 2) == 1) {
                board[boardIndex] = Piece(!myPieceOnTop, bottomPiecesColor)
               }
           }
            //set top
           if ((boardIndex / 8) == 0 || (boardIndex / 8) == 2) {
               if ((boardIndex % 2) == 1) {
                board[boardIndex] = Piece(myPieceOnTop, topPiecesColor)
               }
           }
           if ((boardIndex / 8) == 1) {
               if ((boardIndex % 2) == 0) {
                board[boardIndex] = Piece(myPieceOnTop, topPiecesColor)
               }
           }
        }
        return board
    }
    func processRequest(board:[Piece], indexPath:IndexPath) -> [Piece] {
        GameModel.board = board
        let index:Int = isPiecePicked()
        if index == -1 {
            if isMyPiece(index: indexPath.row) {
                GameModel.board[indexPath.row].isPicked = true
                findRegularPathForPieceIn(index: indexPath.row)
                print("mine")
            }
        }
        else {
            clearPaths()
            clearPicks()
            //piece at index is already picked
           
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
    
    private func findRegularPathForPieceIn (index:Int) {
        if GameModel.board[index].pieceType != nil {
            for direction in Direction.allCases {
                if !isOutOfBoardBounds(from: index, to: index + direction.rawValue) {
                    if GameModel.board[index + direction.rawValue].pieceType == nil {
                        GameModel.board[index + direction.rawValue].isOnPath = true
                    print("path found to \(index + direction.rawValue)")
                    }
                }
            }
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
        if GameModel.board[index].isMyPiece == true {
           return true
       }
        return false
    }
    
    private func movePiece (from:Int, to:Int) -> Bool
    {
        if GameModel.board[from].isMyPiece != true {
            return false
        }
        print("moving now")
        GameModel.board[from].isPicked = false
        GameModel.board[to] = GameModel.board[from]
        GameModel.board[from] = Piece(false, nil)
        
        return true
    }
    
       
}

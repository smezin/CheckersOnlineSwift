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
    static var board:[Piece?] {get set}
}
enum Direction:Int
{
    case upRight = -7
    case downRight = 9
    case upLeft = -9
    case downLeft = 7
}

class GameModel: NSObject, GameData {
 
   // static var board:[Piece?] = Array(repeating: Piece(isMyPiece: false, pieceType: nil), count: 64)
    static var board:[Piece?] = Array()
    
    func setBoardForNewGame(board:[Piece?]) -> [Piece?] {
        var board = board
        for boardIndex:Int in 0..<64
        {
            board[boardIndex] = Piece(isMyPiece: false, pieceType: nil)
            if ((boardIndex / 8) == 0 || (boardIndex / 8) == 2) {
                if ((boardIndex % 2) == 1) {
                    board[boardIndex] = Piece(isMyPiece: true, pieceType: .white_pawn)
                }
            }
            if ((boardIndex / 8) == 1) {
                if ((boardIndex % 2) == 0) {
                    board[boardIndex] = Piece(isMyPiece: true, pieceType: .white_pawn)
                }
            }
            if ((boardIndex / 8) == 5 || (boardIndex / 8) == 7) {
                if ((boardIndex % 2) == 0) {
                    board[boardIndex] = Piece(isMyPiece: false, pieceType: .black_pawn)
                }
            }
            if ((boardIndex / 8) == 6) {
               if ((boardIndex % 2) == 1) {
                   board[boardIndex] = Piece(isMyPiece: false, pieceType: .black_pawn)
               }
           }
        }
        return board
    }
    func processRequest(board:[Piece?], indexPath:IndexPath) -> [Piece?] {
        GameModel.board = board
        let index:Int = isPiecePicked()
        if index == -1 {
            if isMyPiece(index: indexPath.row) {
                GameModel.board[indexPath.row]?.isPicked = true
                findPathForPieceIn(index: indexPath.row)
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
            GameModel.board[index]?.isOnPath = false
        }
    }
    
    private func clearPicks () {
        for index:Int in 0..<64 {
            GameModel.board[index]?.isPicked = false
        }
    }
    
    
    private func findPathForPieceIn (index:Int) {
        if GameModel.board[index]?.pieceType != nil {
            if GameModel.board[index + Direction.downRight.rawValue]?.pieceType == nil {
                GameModel.board[index + Direction.downRight.rawValue]?.isOnPath = true
                print("path found to \(index + Direction.downRight.rawValue)")
            }
            if GameModel.board[index + Direction.downLeft.rawValue]?.pieceType == nil {
                GameModel.board[index + Direction.downLeft.rawValue]?.isOnPath = true
                print("path found to \(index + Direction.downLeft.rawValue)")
            }    
        }
    }
    
    private func isPiecePicked () -> Int {
        for index in 0..<64 {
            if (GameModel.board[index] != nil) {
                if GameModel.board[index]?.isPicked == true {
                    return index
                }
            }
        }
        return -1
    }
    private func isMyPiece (index:Int) -> Bool {
        if GameModel.board[index] != nil {
           if GameModel.board[index]?.isMyPiece == true {
               return true
           }
       }
        return false
    }
    private func movePiece (from:Int, to:Int) -> Bool
    {
        if GameModel.board[from]?.isMyPiece != true {
            return false
        }
        if GameModel.board[to] != nil {
            return false
        }
        print("moving now")
        GameModel.board[from]?.isPicked = false
        GameModel.board[to] = GameModel.board[from]
        GameModel.board[from] = Piece(isMyPiece: false, pieceType: nil)
        
        return true
    }
    
       
}

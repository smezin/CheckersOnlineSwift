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

class GameModel: NSObject, GameData {
 
    static var board:[Piece?] = Array(repeating: nil, count: 64)
    
    func setBoardForNewGame(board:[Piece?]) -> [Piece?] {
        var board = board
        for boardIndex:Int in 0..<64
        {
            if ((boardIndex / 8) == 0 || (boardIndex / 8) == 2) {
                if ((boardIndex % 2) == 1) {
                    board[boardIndex] = Piece(true, Piece.PieceType.white_pawn, boardIndex)
                }
            }
            if ((boardIndex / 8) == 1) {
                if ((boardIndex % 2) == 0) {
                    board[boardIndex] = Piece(true, Piece.PieceType.white_pawn, boardIndex)
                }
            }
            if ((boardIndex / 8) == 5 || (boardIndex / 8) == 7) {
                if ((boardIndex % 2) == 0) {
                    board[boardIndex] = Piece(false, Piece.PieceType.black_pawn, boardIndex)
                }
            }
            if ((boardIndex / 8) == 6) {
               if ((boardIndex % 2) == 1) {
                   board[boardIndex] = Piece(false, Piece.PieceType.black_pawn, boardIndex)
               }
           }
        }
        return board
    }
    func processRequest(board:[Piece?], indexPath:IndexPath) -> [Piece?] {
        GameModel.board = board
        let index:Int = isPiecePicked()
        if (index == -1) {
           //no picked piece on the board, send indexPath to check what next
        }
        else {
            //piece at index is already picked
        }
        
        return GameModel.board
    }
    private func isPiecePicked () -> Int {
        for index in 0..<64 {
            if (GameModel.board[index] != nil) {
                if(GameModel.board[index]?.isPicked == true){
                    return index
                }
            }
        }
        return -1
    }
    
    
       
}

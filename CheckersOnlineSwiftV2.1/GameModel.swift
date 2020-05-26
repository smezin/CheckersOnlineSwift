//
//  GameModel.swift
//  CheckersOnlineSwiftV2.1


import UIKit
import SocketIO

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
    static var isMyTurn:Bool = true
    
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
        setTopPieces(isPieceMine: myPieceOnTop, pieceType: topPiecesColor!)
        setBottomPieces(isPieceMine: !myPieceOnTop, pieceType: bottomPiecesColor!)

        return GameModel.board
    }
         
    func processRequest(board:[BoardSquare], indexPath:IndexPath) -> [BoardSquare] {
        if (!GameModel.isMyTurn) {
            return board
        }
        var didMove:Bool = false
        var isTurnEnded:Bool = false
        let index:Int? = indexOfPickedPiece()
       
        if index == nil { //no picked piece (square)
            if isMyPiece(index: indexPath.row) {
                GameModel.board[indexPath.row].isPicked = true
                findPathForPieceAt(index: indexPath.row)
            }
        }
        else { //piece or square at 'index' picked
            let piece:Piece? = GameModel.board[index!] as? Piece
            if GameModel.board[indexPath.row].isOnPath {
                didMove = movePiece(from: index!, to: indexPath.row)
                if piece?.status == .moving {
                    clearPaths()
                    findConsecutiveKillPathFor(index: indexPath.row)
                } else {
                    clearPaths(); clearPicks()
                }
            } else {
                clearPaths(); clearPicks()
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
            let pieceLocation:Int = (didMove ? indexPath.row:index)!
            coronate(piece: GameModel.board[pieceLocation] as? Piece)
            if didIwin() {
                print("I WON")
            }
            switchPlayer()
        }
        return GameModel.board
    }
    
    //Game management
    private func findPathForPieceAt (index:Int, markPath:Bool = true) -> Bool{
        let piece:Piece? = GameModel.board[index] as? Piece
        var isPathFound = false
        if piece == nil {
            return false
        }
        if piece?.forwardIs == .up {
            isPathFound = findPathInDirections(index, markPath: markPath, .upLeft, .upRight)
        }
        if piece?.forwardIs == .down {
            isPathFound = findPathInDirections(index, markPath: markPath, .downLeft, .downRight)
            
        }
        if !isPathFound {
            piece?.isPicked = false
        }
        return isPathFound
    }
    
    private func findPathInDirections (_ index:Int, isQueen:Bool = false, markPath:Bool = true, _ directions:Direction...) -> Bool {
        
        var directions = directions
        var isQueen = isQueen
        var isPathFound = false
        if !isQueen {
            if let piece:Piece = GameModel.board[index] as? Piece {
                if piece.pieceType == .white_queen || piece.pieceType == .black_queen {
                    isQueen = true
                }
            }
        }
        if isQueen && directions.count > 1 {
            directions = Direction.allCases
        }
        for direction in directions {
            if !isOutOfBoardBounds(from: index, to: index + direction.rawValue) {
                if let pieceOnDirection = GameModel.board[index + direction.rawValue] as? Piece {
                    if !pieceOnDirection.isMyPiece! {
                        if !isOutOfBoardBounds(from: index + direction.rawValue, to: index + 2*direction.rawValue) && GameModel.board[index + 2*direction.rawValue] as? Piece == nil {
                            if markPath {
                                GameModel.board[index + 2*direction.rawValue].isOnPath = true
                            }
                            isPathFound = true
                        }
                    }
                } else {
                    if markPath {
                        GameModel.board[index + direction.rawValue].isOnPath = true
                    }
                    isPathFound = true
                    if isQueen { //recursive path find
                        if !findPathInDirections(index+direction.rawValue, isQueen:true, markPath:markPath ,direction) {
                        }
                    }
                }
            }
        }
        return isPathFound
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
            piece.isPicked = false
        }
    }
    
    private func movePiece (from:Int, to:Int) -> Bool {
        let piece:Piece? = GameModel.board[from] as? Piece
        if piece != nil && !piece!.isMyPiece! {
            return false
        }
        if GameModel.board[to] is Piece {
            return false
        }
        
        GameModel.board[to] = GameModel.board[from]
        GameModel.board[from] = BoardSquare()
        let reverseStep:Direction = getOppositeDirection(from: from, to: to)!
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
    
    private func coronate (piece:Piece?) {
           if piece == nil {
               return
           }
           let index:Int = GameModel.board.firstIndex(of: piece!)!
           let queenType:Piece.PieceType = ((piece!.pieceType == .white_pawn) ? .white_queen: .black_queen)
           
           if piece?.forwardIs == .up {
               if index < 8 {
                   GameModel.board[index] = Piece(isMyPiece: true, pieceType: queenType, forwardIs: .up)
               }
           }
           if piece?.forwardIs == .down {
               if index > 55 {
                   GameModel.board[index] = Piece(isMyPiece: true, pieceType: queenType, forwardIs: .up)
               }
           }
       }
    
    private func switchPlayer () {
        for index:Int in 0..<64 {
            if let piece:Piece = GameModel.board[index] as? Piece {
                piece.isMyPiece = !piece.isMyPiece!
            }
        }
        //GameModel.isMyTurn = false
        PlayersViewController.shared.sendBoard(GameModel.board)
        
    }
    
    private func didIwin () -> Bool {
        for index in 0..<64 {
            if let piece:Piece = GameModel.board[index] as? Piece {
                if !piece.isMyPiece! {
                    if findPathForPieceAt(index: index, markPath: false) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    //Utility func
    private func setEmptyBoard () {
        GameModel.board.removeAll()
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
           if ((boardIndex / 8) == 0 || (boardIndex / 8) == 2) {
               if ((boardIndex % 2) == 1) {
                   GameModel.board[boardIndex] = Piece(isMyPiece: isPieceMine, pieceType: pieceType, forwardIs: .down)
               }
           }
           if ((boardIndex / 8) == 1) {
              if ((boardIndex % 2) == 0) {
               GameModel.board[boardIndex] = Piece(isMyPiece: isPieceMine, pieceType: pieceType, forwardIs: .down)
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
       
    private func indexOfPickedPiece () -> Int? {
       for index in 0..<64 {
           if GameModel.board[index].isPicked == true {
               return index
           }
       }
       return nil
   }
    
    private func getOppositeDirection (from:Int, to:Int) ->Direction? {
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
   
    private func isMyPiece (index:Int) -> Bool {
       let piece:Piece? = GameModel.board[index] as? Piece
       if piece != nil && piece!.isMyPiece! {
          return true
      }
       return false
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
    
}

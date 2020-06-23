import UIKit

//handle JSONs and strings
extension PlayersViewController {
    func stringify (json:[String: Any]) -> String {
        var convertedString:String = ""
        do {
            let data =  try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            convertedString = String(data: data, encoding: String.Encoding.utf8) ?? "Conversion error"
        } catch let myJSONError {
            print("from stringify", myJSONError)
        }
        return convertedString
    }
    func convertPlayersToDisplayDescription () {
        self.playersAtDispalyFormat = []
        for player in idlePlayers {
            let playerDisplayDescription = self.convertPlayerToDisplayDescription(player: player)
            playersAtDispalyFormat.append(playerDisplayDescription)
        }
    }
    func createPlayersNamesList (allPlayers:[[String:Any]]) -> [String] {
        var namesList:[String] = []
        for player in allPlayers {
            let name = self.convertPlayerToDisplayDescription(player: player)
            namesList.append(name)
        }
        return namesList
    }
    func convertPlayerToDisplayDescription (player:[String:Any]) -> String {
        let userDetails = player["user"] ?? player
        let displayDescription = (userDetails as! [String:Any])["userName"] as! String
        return displayDescription
    }
    func boardifyJson (jsonBoard:[String:Any]) -> [BoardSquare] {
        var board:[BoardSquare] = Array()
        for index:Int in 0 ..< 64 {
            let strIndex = String(index)
            let currentSquare:[String:Any] = jsonBoard[strIndex] as! [String : Any]
            if currentSquare["type"] as! String == "boardSquare" {
                board.append(BoardSquare())
            } else if currentSquare["type"] as! String == "piece" {
                let isMyPiece:Bool = currentSquare["isMyPiece"] as! Bool
                let forwardIs:Piece.ForwardIs = currentSquare["forwardIs"] as! String == "up" ? .up:.down
                let pieceType:Piece.PieceType = self.convertStringToPieceType(piece: currentSquare["pieceType"] as! String)
                board.append(Piece(isMyPiece: isMyPiece, pieceType: pieceType, forwardIs: forwardIs))
            }
        }
        return board
    }
    private func convertStringToPieceType (piece:String) -> Piece.PieceType {
        var pieceType:Piece.PieceType? = nil
        switch piece {
        case "blackPawn":
            pieceType = .black_pawn
        case "blackQueen":
            pieceType = .black_queen
        case "whitePawn":
            pieceType = .white_pawn
        case "whiteQueen":
            pieceType = .white_queen
        default:
            pieceType = nil
        }
        return pieceType!
    }
}

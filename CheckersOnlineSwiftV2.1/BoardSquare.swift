//represents empty square on board
import UIKit

class BoardSquare: NSObject {
    var isOnPath:Bool!
    var isPicked:Bool!
    
    override init() {
        isOnPath = false
        isPicked = false
    }
}

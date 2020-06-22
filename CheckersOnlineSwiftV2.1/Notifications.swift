import UIKit

extension Notification.Name {
    static let loginSuccess = Notification.Name("loginSuccess")
    static let loginFailure = Notification.Name("loginFailure")
    static let logout = Notification.Name("logout")
    static let enteredRoom = Notification.Name("enteredRoom")
    static let boardSent = Notification.Name("boardSent")
    static let boardReceived = Notification.Name("boardReceived")
    static let iWon = Notification.Name("iWon")
    static let playerResigned = Notification.Name("playerResigned")
    static let playerWon = Notification.Name("playerWon")
    static let playerLost = Notification.Name("playerLost")
    static let makePickSound = Notification.Name("makePickSound")
    static let makeMoveSound = Notification.Name("makeMoveSound")
    static let closeActiveGame = Notification.Name("closeActiveGame")
    static let appExit = Notification.Name("appExit")
}

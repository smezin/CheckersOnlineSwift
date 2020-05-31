import UIKit

extension Notification.Name {
    static let loginSuccess = Notification.Name("loginSuccess")
    static let loginFailure = Notification.Name("loginFailure")
    static let logout = Notification.Name("logout")
    static let enteredRoom = Notification.Name("enteredRoom")
    static let boardSent = Notification.Name("boardSent")
    static let boardReceived = Notification.Name("boardReceived")
    static let iWon = Notification.Name("iWon")
    static let iLost = Notification.Name("iLost")
    static let showWinMessage = Notification.Name("showWinMessage")
    static let showLostMessage = Notification.Name("showLostMessage")
}

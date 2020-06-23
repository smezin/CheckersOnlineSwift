import UIKit
import AVFoundation

extension GameViewController {
    @objc func makeMoveSound () {
        if GameViewController.settings.soundOn {
            AudioServicesPlaySystemSound(GameViewController.settings.moveSoundID)
        }
    }
    @objc func makePickSound () {
        if GameViewController.settings.soundOn {
            AudioServicesPlaySystemSound(GameViewController.settings.pickSoundID)
        }
    }
    @objc func makeTurnPassSound () {
        if GameViewController.settings.soundOn {
            AudioServicesPlaySystemSound(GameViewController.settings.BoardReceivedSoundID)
        }
    }
}

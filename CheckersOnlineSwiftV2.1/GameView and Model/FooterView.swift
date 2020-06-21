
import UIKit

class FooterView: UICollectionReusableView {
   
    @IBOutlet weak var turnsImageView: UIImageView!
    var gameID:String = ""
    let nc = NotificationCenter.default
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func resignGameButton(_ sender: Any) {
        self.nc.post(name: .iLost, object: nil, userInfo: ["gameID":self.gameID])
        self.nc.post(name: .playerLost, object: nil, userInfo: ["gameID":self.gameID])
    }
}

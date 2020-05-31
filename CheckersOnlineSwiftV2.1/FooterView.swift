
import UIKit

class FooterView: UICollectionReusableView {
   
    @IBOutlet weak var turnsImageView: UIImageView!
    let nc = NotificationCenter.default
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func resignGameButton(_ sender: Any) {
        self.nc.post(name: .iLost, object: nil)
    }
}

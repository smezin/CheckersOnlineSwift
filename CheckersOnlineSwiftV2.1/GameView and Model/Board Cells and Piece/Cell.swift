
import UIKit

class Cell: UICollectionViewCell {
    
    static var identifier: String = "Cell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.reset()
    }
    
    func reset() {
        let subviewTag = GameSettings().appSubviewsTag
        let subViews = self.subviews
        for subview in subViews {
            if subview.tag == subviewTag {
                subview.removeFromSuperview()
            }
        }
    }
}

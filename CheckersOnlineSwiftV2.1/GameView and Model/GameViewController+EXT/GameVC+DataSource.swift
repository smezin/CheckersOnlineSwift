
import UIKit

//Handling data source
extension GameViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 64
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        let cellFrame = CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: cell.bounds.size.height)
        cell.backgroundView = getCellBackgroundView(index: indexPath.row)
        
        //animate pick
        if let cellImageView = getCellImageView(indexPath.row, cellFrame) {
            cell.addSubview(cellImageView)
            if self.board[indexPath.row].isPicked {
                cellImageView.center.y -= CGFloat(GameViewController.settings.bounceHeight)
                UIImageView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                    cellImageView.center.y += CGFloat(GameViewController.settings.bounceHeight)
                })
            }
        } else {
            //remove subview that might have from reusing
            let subViews = cell.subviews
            for subview in subViews {
                if subview.tag == imageViewsTag {
                    subview.removeFromSuperview()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind.isEqual(UICollectionView.elementKindSectionHeader) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GameViewController.settings.headerViewId, for: indexPath) as! HeaderView
            header.backgroundColor = self.view.backgroundColor
            return header
        } else if kind.isEqual(UICollectionView.elementKindSectionFooter) {
            var footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GameViewController.settings.footerViewId, for: indexPath) as! FooterView
            footer.gameID = self.gameID
            footer.backgroundColor = self.view.backgroundColor
            DispatchQueue.main.async {
                footer = self.updateFooter(footer)
            }
            return footer
        }
        else {
            return UICollectionReusableView()
        }
    }
    
    func getCellImageView (_ index:Int, _ cellFrame:CGRect) -> UIImageView? {
        let boardSquare:BoardSquare = self.board[index]
        var image = UIImage()
        var imageView = UIImageView()
        let piece:Piece? = boardSquare as? Piece
        if piece != nil {
            image = getImageByPieceType(piece: piece)
            imageView = UIImageView(image: image)
        }
        else if boardSquare.isOnPath && GameViewController.settings.showPaths {
            image = UIImage(named: GameViewController.settings.pathMarkImageName)!
            imageView = UIImageView(image: image)
        } else {
            return nil
        }
        imageView.frame = cellFrame
        imageView.tag = imageViewsTag
        return imageView
        
    }
    func getCellBackgroundView (index:Int) -> UIImageView{
        
        var cellImageView:UIImageView
        if (((index / 8) % 2) == 0) {
            if ((index % 2) == 0) {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.lightSquareImageName))
            } else {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.darkSquareImageName))
            }
        } else {
            if ((index % 2) == 1) {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.lightSquareImageName))
            } else {
                cellImageView = UIImageView(image: UIImage(named: GameViewController.settings.darkSquareImageName))
            }
        }
        return cellImageView
    }
    
    func getImageByPieceType (piece:Piece?) -> UIImage
    {
        if piece?.pieceType == nil {
            //remove from view
        }
        var image:UIImage
        switch piece?.pieceType {
        case .white_pawn:
            image = UIImage(named: GameViewController.settings.whitePawnImage)!
        case .black_pawn:
            image = UIImage(named: GameViewController.settings.blackPawnImage)!
        case .white_queen:
            image = UIImage(named: GameViewController.settings.whiteQueenImage)!
        case .black_queen:
            image = UIImage(named: GameViewController.settings.blackQueenImage)!
        default:
            image = UIImage()
        }
        return image
    }
}

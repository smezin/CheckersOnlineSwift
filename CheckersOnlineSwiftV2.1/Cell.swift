//
//  CollectionViewCell.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {
    
    static var identifier: String = "Cell"

        weak var textLabel: UILabel!

        override init(frame: CGRect) {
            super.init(frame: frame)

            let textLabel = UILabel(frame: .zero)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(textLabel)
            NSLayoutConstraint.activate([
                self.contentView.centerXAnchor.constraint(equalTo: textLabel.centerXAnchor),
                self.contentView.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            ])
            self.textLabel = textLabel
            
            self.reset()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            self.reset()
        }

        func reset() {
            self.textLabel.textAlignment = .center
        }
    }

//
//  FooterView.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 02/05/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class FooterView: UICollectionReusableView {
   
    @IBOutlet weak var turnsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if GameModel.isMyTurn {
            turnsLabel.text = "Your turn"
        } else {
            turnsLabel.text = "Opponents turn"
        }
    }
    
}

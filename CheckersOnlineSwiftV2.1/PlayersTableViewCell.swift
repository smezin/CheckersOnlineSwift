//
//  PlayersTableViewCell.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 25/05/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class PlayersTableViewCell: UITableViewCell {

    @IBOutlet weak var playerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

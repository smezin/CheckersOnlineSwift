//
//  ActiveGamesTableViewCell.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 20/06/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class ActiveGamesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var gameNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

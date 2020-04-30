//
//  BoardSquare.swift
//  CheckersOnlineSwiftV2.1
//
//  Created by hyperactive on 30/04/2020.
//  Copyright © 2020 hyperActive. All rights reserved.
//

import UIKit

class BoardSquare: NSObject {
    var isOnPath:Bool!
    var isPicked:Bool!
    
    override init() {
        isOnPath = false
        isPicked = false
    }
}

//
//  TapGestureRecognizer.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/19/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit

class TapGestureRecognizer: UITapGestureRecognizer {
    let identifier: String
    
    private override init(target: Any?, action: Selector?) {
        self.identifier = ""
        super.init(target: target, action: action)
    }
    
    init(target: Any?, action: Selector?, identifier: String) {
        self.identifier = identifier
        super.init(target: target, action: action)
    }
    
    static func == (left: TapGestureRecognizer, right: TapGestureRecognizer) -> Bool {
        return left.identifier == right.identifier
    }
}

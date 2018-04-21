//
//  Extensions.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/17/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation

//Returns a string version of itself
extension UIResponder {
    static var identifier: String {
        return String(describing: self)
    }
}

extension Notification.Name{
    static let reloadProfileCollectionView = Notification.Name("kvReloadCollectionProfile")
}


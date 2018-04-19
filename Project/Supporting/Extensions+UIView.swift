//
//  Extensions+UIView.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/19/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit

extension UIView{
    
    private var disableKeybordWhenTappedGestureRecognizerIdentifier:String {
        return "disableKeybordWhenTapped"
    }
    
    private var disableKeybordWhenTappedGestureRecognizer: TapGestureRecognizer? {
        
        let hideKeyboardGesture = TapGestureRecognizer(target: self, action: #selector(UIView.hideKeyboard), identifier: disableKeybordWhenTappedGestureRecognizerIdentifier)
        
        if let gestureRecognizers = self.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                if let tapGestureRecognizer = gestureRecognizer as? TapGestureRecognizer, tapGestureRecognizer == hideKeyboardGesture, tapGestureRecognizer == hideKeyboardGesture {
                    return tapGestureRecognizer
                }
            }
        }
        return nil
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    var disableKeybordWhenTapped: Bool {
        
        set {
            let hideKeyboardGesture = TapGestureRecognizer(target: self, action: #selector(UIView.hideKeyboard), identifier: disableKeybordWhenTappedGestureRecognizerIdentifier)
            
            if let disableKeybordWhenTappedGestureRecognizer = self.disableKeybordWhenTappedGestureRecognizer {
                removeGestureRecognizer(disableKeybordWhenTappedGestureRecognizer)
                if gestureRecognizers?.count == 0 {
                    gestureRecognizers = nil
                }
            }
            
            if newValue {
                addGestureRecognizer(hideKeyboardGesture)
            }
        }
        
        get {
            return disableKeybordWhenTappedGestureRecognizer == nil ? false : true
        }
    }
}

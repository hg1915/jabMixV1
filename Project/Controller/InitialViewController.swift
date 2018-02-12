

import Foundation
import UIKit
import Firebase

class InitialViewController:UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = Auth.auth().currentUser {
            
        } else {
            
        }
    }
}

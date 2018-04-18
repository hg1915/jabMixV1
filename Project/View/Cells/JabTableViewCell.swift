//
//  JabTableViewCell.swift
//  jabMix1
//
//  Created by Robert Canton on 2018-01-25.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit
import Firebase

class JabTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var jabLabel: UILabel!
    @IBOutlet weak var jabStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.backgroundColor = UIColor.lightGray
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var requestUserID:String?
    
    func setRequest(_ request:Request) {
        usernameLabel.text = request.name
        
        requestUserID = request.isSenderCurrentUser ? request.recipient : request.sender
        
        jabLabel.text = request.isSenderCurrentUser ? "You sent a Jab!🤜" : "You got Jabbed!🤛"
        jabStatusLabel.text = request.status
        
        getUser(requestUserID!) { uid, user in

            guard let user = user, uid == self.requestUserID else { return }
            
            self.usernameLabel.text = user.firstLastName
            if let photoURL = user.photoURL {
                self.profileImageView.loadImageUsingCacheWithUrlString(urlString: photoURL)
            }
        }
        
    }
    
    func getUser(_ uid:String, completion: @escaping ((_ uid:String,_ user:Users?)->())) {
        let ref = Database.database().reference()
        let userRef = ref.child("users/\(uid)")
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            let user = Users(snapshot: snapshot)
            completion(uid, user)
        })
    }
}

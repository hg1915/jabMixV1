//
//  ChatTableViewCell.swift
//  jabMix1
//
//  Created by Robert Canton on 2018-01-21.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unreadDot: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.backgroundColor = UIColor.lightGray
        unreadDot.layer.cornerRadius = unreadDot.bounds.height / 2
        unreadDot.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var partner_uid:String = ""
    var partner:Users?
    func setConversation(_ conversation:Conversation) {
        self.partner_uid = conversation.partner_uid
        self.profileImageView.image = nil
        
        unreadDot.isHidden = conversation.seen
        usernameLabel.text = ""
        messageLabel.text = conversation.recentMessage
        timeLabel.text = conversation.date.timeStringSinceNow()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        getUser(partner_uid) { uid, user in
            self.partner = user
            guard let user = user, uid == self.partner_uid else { return }
            
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

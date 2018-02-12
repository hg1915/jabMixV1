//
//  FindAPartnerCellTableViewCell.swift
//  jabMix1
//
//  Created by HG on 10/19/17.
//  Copyright © 2017 GGTECH. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class FindAPartnerCellTableViewCell: UITableViewCell {

    
    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    
    var storageRef: Storage {
        
        return Storage.storage()
    }
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(user: Users){
        
        self.username.text = user.firstLastName
        self.location.text = "@" + user.username
        let imageURL = user.photoURL!
        
        self.storageRef.reference(forURL: imageURL).getData(maxSize: 10 * 1024 * 1024, completion: { (imgData, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.imageView?.image = UIImage(data: data)
                    }
                }
                
            }else {
                print(error!.localizedDescription)
                
            }
            
        }
            
            
        )
        
        
        
        
        
        
        
        
        
   
    }
    
    
    
    
    
    
    
    
}

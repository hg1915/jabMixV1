

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth



class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var location: UILabel!
    
    
    @IBOutlet weak var bio: UILabel!
    
    
    
    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    
    var storageRef: Storage {
        
        return Storage.storage()
    }
    
    override func layoutSubviews() {
        avatar.layer.cornerRadius = avatar.bounds.height / 2
        avatar.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
        self.avatar.image = nil
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(user: Users){
      
        self.name.text = user.firstLastName
        self.location.text = user.location
        self.bio.text = user.biography
       // self.firstLastName.text = "@" + user.username
        //     let imageURL = user.photoURL!
        
        
        if let imageAvatar = user.photoURL{
            
            avatar.loadImageUsingCacheWithUrlString(urlString: imageAvatar)
        }
        
        
        
    }
    
    
}












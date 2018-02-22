
import Foundation
import Firebase
import FirebaseDatabase

struct Users {
    var email: String!
    var uid: String!
    var ref: DatabaseReference!
    var location: String?
    var photoURL: String!
    var biography: String?
    var key: String?
    var firstLastName: String!
    var interests: String!
    var password: String!
    
    
    init(snapshot: DataSnapshot) {
        
        if let snap = snapshot.value as? [String: Any]{
            self.password = snap["password"] as! String
            self.email = snap["email"] as! String
            self.uid = snap["uid"] as! String
            self.interests = snap["interests"] as! String
            self.location = snap["location"] as! String
            self.photoURL = snap["photoURL"] as! String
            self.biography = snap["biography"] as! String
            self.firstLastName = snap["firstLastName"] as! String
            
        }
        
    }
    
    init(email: String, uid: String) {
        self.email = email
        self.uid = uid
        self.ref = Database.database().reference()
    }
}


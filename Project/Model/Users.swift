
import Foundation
import Firebase
import FirebaseDatabase
import RealmSwift

struct Users: UserInformation {
    var email: String? = ""
    var uid: String? = ""
    var ref: DatabaseReference?
    var location: String? = ""
    var photoURL: String? = ""
    var biography: String? = ""
    var key: String? = ""
    var firstLastName: String? = ""
    var interests: String? = ""
    var password: String? = ""
    
    
    init(snapshot: DataSnapshot) {
        
        if let snap = snapshot.value as? [String: Any]{
            self.password = snap["password"] as? String
            self.email = snap["email"] as? String
            self.uid = snap["uid"] as? String
            self.interests = snap["interests"] as? String
            self.location = snap["location"] as? String
            self.photoURL = snap["photoURL"] as? String
            self.biography = snap["biography"] as? String
            self.firstLastName = snap["firstLastName"] as? String
            
        }
        
    }
    
    init(email: String, uid: String) {
        self.email = email
        self.uid = uid
        self.ref = Database.database().reference()
    }
}

open class UserRealm: Object{
    @objc open dynamic var email: String? = ""
    @objc open dynamic var uid: String? = ""
    @objc open dynamic var ref: DatabaseReference?
    @objc open dynamic var location: String? = ""
    @objc open dynamic var latitude: String? = ""
    @objc open dynamic var longitude: String? = ""
    @objc open dynamic var photoURL: String? = ""
    @objc open dynamic var biography: String? = ""
    @objc open dynamic var key: String? = ""
    @objc open dynamic var firstLastName: String? = ""
    @objc open dynamic var interests: String? = ""
    @objc open dynamic var password: String? = ""
    
    
    //Meta data primary key function returns the string from variable previously created for reference purposes
    override open static func primaryKey() -> String? {
        return "uid"
    }
}

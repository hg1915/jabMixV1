

import Foundation
import Firebase

class Request {
    var key:String
    var sender:String
    var recipient:String
    var name:String
    var location:String
    var when:String
   var whereStr:String
    var message:String
    var timestamp:Double
    var status:String
    
    init(dict: [String: Any]) {
        self.key       = dict["key"] as? String ?? ""
        self.sender    = dict["sender"] as? String ?? ""
        self.recipient = dict["recipient"] as? String ?? ""
        self.name      = dict["name"] as? String ?? ""
        self.location  = dict["location"] as? String ?? ""
        self.when      = dict["when"] as? String ?? ""
        self.whereStr  = dict["where"] as? String ?? ""
        self.message   = dict["message"] as? String ?? ""
        self.timestamp = dict["timestamp"] as? Double ?? 0.0
        self.status    = dict["status"] as? String ?? ""
    }
    
    var isSenderCurrentUser:Bool {
        guard let user = Auth.auth().currentUser else { return false }
        return user.uid == sender
    }
    
}

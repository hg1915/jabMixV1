
import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import UIKit
import SVProgressHUD

struct AuthService{
    
    var dataBaseRef: DatabaseReference!{
        return Database.database().reference()
    }
    
    var storageRef: StorageReference!{
        return Storage.storage().reference()
    }

    
    func signUP(firstLastName: String, email: String, location: String, biography: String, password: String, interests: String, pictureData: NSData!) {
    SVProgressHUD.show()
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil, let unwrappedUser = user{

                self.setUserInfo(firstLastName: firstLastName, user: unwrappedUser, location: location, interests: interests, biography: biography, password: password, pictureData: pictureData)

            }



            else{
                print(error?.localizedDescription)
            }
        }
       
    
    }
    
     func setUserInfo(firstLastName: String, user: User, location: String, interests: String, biography: String, password: String, pictureData: NSData!){
        
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
        let imageRef = storageRef.child(imagePath)
        
    let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(pictureData as Data, metadata: metaData){(newMetaData, error)
            in
            if error == nil{
                let changeRequest = User.createProfileChangeRequest(user)()
                changeRequest.displayName = firstLastName
                if let photoURL = newMetaData!.downloadURL(){
                    changeRequest.photoURL = photoURL
                    
                }
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil{
                      
                        self.saveUserInfo(firstLastName: firstLastName, user: user, location: location, biography: biography, interests: interests, password: password)
                        
                        print("user info set")
                        
                    }else{
                        print(error?.localizedDescription)
                    }
                })
                
            }else{
                print(error?.localizedDescription)
            }
            
        }
        
    }
    
    private func saveUserInfo(firstLastName: String, user: User!, location: String, biography: String, interests: String, password: String){
        
        let userInfo = ["firstLastName": firstLastName,  "email": user.email!, "password": password, "location": location, "interests": interests, "biography": biography, "uid": user.uid, "photoURL": String(describing: user.photoURL!)]
        
        let userRef = dataBaseRef.child("users").child(user.uid)
        userRef.setValue(userInfo) { (error, ref) in
            if error == nil{
                print("USER SAVED")
               
                
                
                
                
                self.logIn(email: user.email!, password: password)
            }else{
                print(error?.localizedDescription)
                
            }
        }
        
    }
    
    func logIn(email: String, password: String){
        
        SVProgressHUD.show()
        
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                if let user = user {
                    print("\(user.displayName!) has been signed in")
                    
                    SVProgressHUD.dismiss()
         

                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logUser()
                    
                }else{
                    print(error?.localizedDescription)
                    
                }
                
            }
        }
    }
    
    func getCurrentUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        dataBaseRef.child("users/\(uid)").observeSingleEvent(of: .value, with: { snapshot in
            print("GOTTY!")
            currentUser = Users(snapshot: snapshot)
        })
    }
    
    
}















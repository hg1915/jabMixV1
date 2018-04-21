//
//  FirebaseUpdate.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/20/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Firebase

enum UserUpdate: String{
    
    case firstLastName
    case email
    case password
    case location
    case interests
    case biography
    case uid
    case profileImage
    case img1
    case img2
    case img3
    case img4
    case img5
    case img6
    
    func type() -> String{
        return self.rawValue
    }
}

func updateUserSingleProperty(user: User, type: UserUpdate, stringValue: String?, imageValue: UIImage?, completion:@escaping(Bool) -> () ){
    
    let dataBaseRef: DatabaseReference = {
        return Database.database().reference()
    }()
    
    let storageRef: StorageReference = {
        return Storage.storage().reference()
    }()
    
    
    if let image = imageValue{
        guard let imgData = UIImageJPEGRepresentation(image, 0.7) else {
            print("Could not convert image to Data in updateUserSingleProperty func")
            return }
        
        let imagePath: String = "images/\(user.uid)/\(type.type())-\(UUID().uuidString).jpg"
        
        let imageRef = storageRef.child(imagePath)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(imgData as Data, metadata: metaData){(newMetaData, error)
            in
            if error == nil{
                let changeRequest = user.createProfileChangeRequest()
                if let photoURL = newMetaData!.downloadURL(){
                    changeRequest.photoURL = photoURL
                    
                    changeRequest.commitChanges(completion: { (error) in
                        if error == nil{
                            let userRef = dataBaseRef.child("users").child((user.uid))
                            
                            if type == UserUpdate.profileImage{
                                let imageString = String(describing: photoURL)
                                
                                userRef.updateChildValues(["photoURL" : imageString])
                                completion(true)
                                
                            } else {
                                let imageString = String(describing: photoURL)
                                userRef.child("images").updateChildValues([type.type():imageString])
                                completion(true)
                                
                            }
                            print("user info set")
                        }
                        completion(false)
                        
                    })
                }
                
            }
            
        }
    } else
        if let data = stringValue{
            user.createProfileChangeRequest().commitChanges(completion: { (error) in
                if error == nil{
                    
                    let userRef = dataBaseRef.child("users").child((user.uid))
                    
                    userRef.updateChildValues([type:data])
                    
                    print("user info set")
                }
            })
    }
    
}

func updateUserDictionary(user:User, info: Dictionary<UserUpdate, Any>){
    
    user.createProfileChangeRequest().commitChanges(completion: { (error) in
        if error == nil{
            
            for value in info{
                if let update = value.value as? String{
                    
                    updateUserSingleProperty(user: user, type: value.key, stringValue: update, imageValue: nil, completion: {_ in })
                    
                } else
                    if let image = value.value as? UIImage{
                        
                        updateUserSingleProperty(user: user, type: value.key, stringValue: nil, imageValue: image, completion: {_ in})
                }
            }
            
            print("user info set")
        }
    })
}

//
//  AddImagesViewModel.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/20/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class AddImagesViewModel: NSObject{
    
    var images = [String]()
    
    override init() {
        super.init()
        loadImages()
       
    }
    
    func loadImages(){
        
            let userRef = dataBaseRef.child("users/\(Auth.auth().currentUser!.uid)")
            
            userRef.observe(.value, with: { (snapshot) in
                
                let user = Users(snapshot: snapshot)
                
                if let username = user.firstLastName{
                    self.name.text = username
                    self.nameOld = username
                }
                
                if let pass = user.password{
                    self.passwordOld = pass
                }
                
                if let userLocation = user.location{
                    self.location.text = userLocation
                    self.locationOld = userLocation
                }
                if let bio = user.biography{
                    self.biog.text = bio
                    self.bioOld = bio
                }
                if let interests = user.interests{
                    self.interests.text = interests
                    self.interestsOld = interests
                }
                
                if let imageOld = user.photoURL{
                    
                    if !imageOld.isEmpty{
                        
                        //  let imageURL = user.photoURL!
                        
                        
                        
                        self.storageR.reference(forURL: imageOld).getData(maxSize: 10 * 1024 * 1024, completion: { (imgData, error) in
                            
                            if error == nil {
                                DispatchQueue.main.async {
                                    if let data = imgData {
                                        self.profileImage.image = UIImage(data: data)
                                    }
                                }
                                
                            }else {
                                print(error!.localizedDescription)
                                
                            }
                            
                        }
                            
                            
                        )
                    }
                    
                    
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
            
            
        
    }
}

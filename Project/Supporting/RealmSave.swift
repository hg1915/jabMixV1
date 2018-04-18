//
//  RealmSave.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/17/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation

public func saveUserToDevice(_ user: UserRealm, completion: @escaping (Bool)->()){
    do{
        try realm.write {
            if let use = realm.object(ofType: UserRealm.self, forPrimaryKey: user.uid){
                use.email = !user.email!.isEmpty ? user.email : use.email
                use.ref = user.ref != nil ? user.ref : use.ref
                use.location = !user.location!.isEmpty ? user.location : use.location
                use.latitude = !user.latitude!.isEmpty ? user.latitude : use.latitude
                use.longitude = !user.longitude!.isEmpty ? user.longitude : use.longitude
                use.photoURL = !user.photoURL!.isEmpty ? user.photoURL : use.photoURL
                use.biography = !user.biography!.isEmpty ? user.biography : use.biography
                use.key = !user.key!.isEmpty ? user.key : use.key
                use.firstLastName = !user.firstLastName!.isEmpty ? user.firstLastName : use.firstLastName
                use.interests = !user.interests!.isEmpty ? user.interests : use.interests
                use.password = !user.password!.isEmpty ? user.password : use.password
                
            }
            completion(false)
        }
    }
    catch{
       print("Error")
        completion(false)
    }
}

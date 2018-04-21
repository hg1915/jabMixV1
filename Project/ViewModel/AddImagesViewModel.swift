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
import FirebaseAuth
import FirebaseStorage

class AddImagesViewModel: NSObject{
    
    var viewController: UIViewController?
    var images = [String]()
    var dataBaseRef: DatabaseReference {
        return Database.database().reference()
    }
    
    override init() {
        super.init()
       
    }
    
    
    
    func loadImages(){
        
            let userRef = dataBaseRef.child("users/\(Auth.auth().currentUser!.uid)/images")
            
            userRef.observe(.value, with: { (snapshot) in
                print(snapshot as Any)
                if let images = snapshot.value as? Dictionary<String, String>{
                    self.images.removeAll()
                    for image in images{
                        self.images.append(image.value)                    }
                    NotificationCenter.default.post(.init(name: .reloadProfileCollectionView))
                    
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
    }
}

extension AddImagesViewModel: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if images.count <= 5{
            return images.count + 1
        }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddImagesCell.identifier, for: indexPath) as? AddImagesCell{
            
            cell.viewController = self.viewController
            
            if images.count < 6 && images.count > 0{
                if indexPath.row < images.count{
                    cell.configure(url: images[indexPath.row])
                }
                
            }
            
            return cell
        }
        
        return AddImagesCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("add image selected")
                var type: UserUpdate!
                if let vc = viewController as? ProfileTabViewController{
                    if indexPath.row == 0 {type = .img1} else if indexPath.row == 1{type = .img2} else if indexPath.row == 2{type = .img3} else if indexPath.row == 3{type = .img4} else if indexPath.row == 4{type = .img5} else if indexPath.row == 5{type = .img6}
                    vc.imageType = type
                    vc.choosePictureAction()
                }
            
            
        
    }
    
    
}



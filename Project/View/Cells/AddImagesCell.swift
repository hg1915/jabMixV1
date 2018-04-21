//
//  AddImagesCell.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/20/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit
import FirebaseStorage

class AddImagesCell: UICollectionViewCell {
    
    @IBOutlet weak var addImageButton: UIButton!
    
    weak var viewController: UIViewController?
    
    lazy var storage: Storage = {
        return Storage.storage()
    }()
    
    
    func configure(url: String){
        
        storage.reference(forURL: url).getData(maxSize: 10 * 1024 * 1024, completion: { (imgData, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        
                        self.addImageButton.setImage(UIImage(data:data), for: .normal)
                        self.addImageButton.imageView?.contentMode = .scaleAspectFill
                        self.addImageButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
                        self.addImageButton.translatesAutoresizingMaskIntoConstraints = false
                        
                    }
                }
            }else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addImageButton.isEnabled = false
    }
    
    //Nib reference
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}

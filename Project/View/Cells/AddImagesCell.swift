//
//  AddImagesCell.swift
//  jabMix1
//
//  Created by Jay Balderas on 4/20/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit

class AddImagesCell: UICollectionViewCell {
    @IBOutlet weak var addImageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addImageButton.layer.borderColor = UIColor.blue.cgColor
        addImageButton.layer.borderWidth = 3
        addImageButton.layer.cornerRadius = 10
        addImageButton.clipsToBounds = true
    }
    
    //Nib reference
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

}

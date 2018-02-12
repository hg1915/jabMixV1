//
//  TermsViewController.swift
//  jabMix1
//
//  Created by HG on 2/11/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
termsView.isEditable = false
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var termsView: UITextView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

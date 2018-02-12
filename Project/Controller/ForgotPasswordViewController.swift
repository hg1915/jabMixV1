//
//  ForgotPasswordViewController.swift
//  jabMix1
//
//  Created by HG on 12/13/17.
//  Copyright © 2017 GGTECH. All rights reserved.
//

import UIKit
import Firebase
class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: DesignableUITextField!
   
    
    
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func showAlert(message : String) -> Void {
        let alert = UIAlertController(title: "Password Reset Sent", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func submitAction(_ sender: Any) {
        
        if isValid(emailTextField.text!) == true{
            print("Test 1 passed")
        }else{
            print("Test 1 failed")
        }
        
        if  isValidEmail(testStr: emailTextField.text!) == true {
            print("test 2 passed")
        }else {
            print("test 2 failed")
        }
        
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in

            print(self.emailTextField.text)
            self.showAlert(message: "Thank you")
            // Your code here
        }
    }
    
    @IBOutlet weak var forgotPasswordOutlet: UIButton!
 
    func setUpButtons(){
        forgotPasswordOutlet.layer.borderWidth = 1
        forgotPasswordOutlet.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
      // navigationController?.navigationBar.isHidden = true
//    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
//        
//        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "FORGOT PASSWORD"
        
        self.tabBarController?.tabBar.isHidden = true
       
        
     //   setUpButtons()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

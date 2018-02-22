
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import MessageUI
import Foundation

class LoginWithEmailViewController: UIViewController, UIAlertViewDelegate, MFMailComposeViewControllerDelegate {
    var authService = AuthService()
    
    @IBAction func signInButton(_ sender: Any) {
  
        self.view.endEditing(true)
        let email = emailText.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordText.text!
        
        if finalEmail.isEmpty || password.isEmpty {
            
            let alertController = UIAlertController(title: "Error!", message: "Please fill in all the fields.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        }else {
          SVProgressHUD.show()
  
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
    
                if error == nil {
                    if let user = user {
                        print("\(user.displayName!) has been signed in")
                        
                       SVProgressHUD.dismiss()
                 self.performSegue(withIdentifier: "signInHome", sender: nil)
                        
                    }else{
                         SVProgressHUD.dismiss()
                       print("error")
                       
                        
                        
                        print(error?.localizedDescription as Any)
                    }
                }
                else {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Low Blow!", message: "Incorrect Credentials", preferredStyle: .alert)
                   
                    
                    let action1 = UIAlertAction(title: "Contact Support", style: .default, handler: { (action) -> Void in
                       
                        let mailComposeViewController = self.configuredMailComposeViewController()
                        if MFMailComposeViewController.canSendMail() {
                            self.present(mailComposeViewController, animated: true, completion: nil)
                        } else {
                            self.showSendMailErrorAlert()
                        }
                        
                        print("ACTION 1 selected!")
                    })
                    
               
                    
                    // Cancel button
                    let cancel = UIAlertAction(title: "Try Again", style: .default , handler: { (action) -> Void in })
                    
                    
                    // Add action buttons and present the Alert
                    alert.addAction(action1)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                    

                }
            }
        }
     
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["Hello@jabmix.com"])
        mailComposerVC.setSubject("CONTACT")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func enter(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewTabBarViewController") as! UIViewController
        // Alternative way to present the new view controller
        self.navigationController?.present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var emailText: DesignableUITextField!{
        didSet {
            emailText.delegate = self
        }
    }
    
    
    @IBOutlet weak var passwordText: DesignableUITextField!{
        didSet{  passwordText.delegate = self
    }
}
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    
    
    @IBOutlet weak var signInButtonOutlet: UIButton!
    
    
    
    func setUpButtons(){
        signInButtonOutlet.layer.borderWidth = 1
        signInButtonOutlet.layer.borderColor = UIColor.white.cgColor
        signUpButtonOutlet.layer.borderWidth = 1
        signUpButtonOutlet.layer.borderColor = UIColor.white.cgColor
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.title = "LOGIN"
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension LoginWithEmailViewController: UITextFieldDelegate{
    
    
    
    // Dismissing the Keyboard with the Return Keyboard Button
    @objc func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        return true
    }

    
}














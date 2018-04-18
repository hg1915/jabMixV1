
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import MessageUI
import Foundation
import TwitterKit

protocol LoginViewControllerDelegate: class{
    
}

class LoginViewController: UIViewController, UIAlertViewDelegate, MFMailComposeViewControllerDelegate {
    
    //MARK: Variables
    var authService = AuthService()
    weak var delegate: LoginViewControllerDelegate?
    
    //MARK: Outlets
    @IBOutlet weak var emailText: DesignableUITextField!{
        didSet {
            emailText.delegate = self
        }
    }
    
    
    @IBOutlet weak var passwordText: DesignableUITextField!{
        didSet{  passwordText.delegate = self
        }
    }

    @IBOutlet weak var signInButtonOutlet: UIButton!
    
    //MARK: Actions
    
    @IBAction func facebookLoginButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func twitterLoginButtonPressed(_ sender: UIButton) {
        // Twitter login attempt
        TWTRTwitter.sharedInstance().logIn(completion: { session, error in
            if let session = session {
                // Successful log in with Twitter
                print("signed in as \(session.userName)");
                let info = "Username: \(session.userName) \n User ID: \(session.userID)"
//                self.didLogin(method: "Twitter", info: info)
            } else {
                print("error: \(error?.localizedDescription)");
            }
        })
    }
    
    
    @IBAction func signInButton(_ sender: Any) {
        signIn()
        
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
        
        // Alternative way to present the new view controller
        self.navigationController?.present(instantiateMainTabBarViewController(), animated: true, completion: nil)
        
    }
    
    func signIn(){
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
                        
                        self.present(instantiateMainTabBarViewController(), animated: true, completion: nil)
                        
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

    
    func setUpButtons(){
        signInButtonOutlet.layer.borderWidth = 1
        signInButtonOutlet.layer.borderColor = UIColor.white.cgColor
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.title = "Login"
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension LoginViewController: UITextFieldDelegate{
    
    
    
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














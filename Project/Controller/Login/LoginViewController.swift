
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import MessageUI
import Foundation
import TwitterKit

protocol LoginViewControllerDelegate: class{
    func loginEmailPressed(_ viewController: UIViewController, email: String, pass: String)
    func facebookLoginPressed(_ viewController: UIViewController)
    func twitterLoginPressed(_ viewContoller: UIViewController)
    
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
        delegate?.facebookLoginPressed(self)
    }
    
    @IBAction func twitterLoginButtonPressed(_ sender: UIButton) {
        // Twitter login attempt
        delegate?.twitterLoginPressed(self)
    }
    
    
    @IBAction func signInButton(_ sender: Any) {
        
        delegate?.loginEmailPressed(self, email:  emailText.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), pass: passwordText.text!)
        self.view.endEditing(true)
        
        
        
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
    

    
    func setUpButtons(){
        signInButtonOutlet.layer.borderWidth = 1
        signInButtonOutlet.layer.borderColor = UIColor.white.cgColor
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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














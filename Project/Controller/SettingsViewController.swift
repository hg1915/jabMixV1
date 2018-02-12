

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import CoreLocation
import MessageUI
import Foundation

class SettingsViewController: UIViewController,UIAlertViewDelegate, MFMailComposeViewControllerDelegate {

   var photoUrl = String()
    
    @IBAction func helpButton(_ sender: Any) {
        let mailComposeViewController = self.configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBOutlet weak var nameTextField: DesignableUITextField!
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
    func showAlert(message : String) -> Void {
        let alert = UIAlertController(title: "Updated", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func updateName(_ sender: Any) {
     
        var nameNew = nameTextField.text
        
        if  (nameTextField.text?.isEmpty)! {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "Low Blow", message: " Please fill in a new name.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }else{
        
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.commitChanges(completion: { (error) in
                if error == nil{
                    
                    let user = Auth.auth().currentUser
                    
                    let userInfo = ["firstLastName": nameNew,  "email": self.emailString, "password": self.passwordOld, "location": self.locationOld, "interests": self.interestsOld, "biography": self.biog, "uid": self.uid, "photoURL": self.photoUrl]
                    
                    let userRef = self.dataBaseRef.child("users").child((user?.uid)!)
                    userRef.setValue(userInfo)
                    
                    print("user info set")
                    
                }
                
                
            })
    self.view.endEditing(true)
        }
        showAlert(message: "Name Changed")
        
    }
    
    
    @IBOutlet weak var emailText: DesignableUITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var updateEmail: UIButton!
    
    @IBOutlet weak var updateLocation: UIButton!

    
    @IBOutlet weak var profileImage: UIImageView!
    

    @IBAction func updatePassword(_ sender: Any) {
        
        var pictureD: Data? = nil
        if let imageView = self.profileImage.image{
            pictureD = UIImageJPEGRepresentation(imageView, 0.70)
        }
        
        let newPassword = password.text
        let finalEmail = self.emailString
        
        if  (password.text?.isEmpty)! {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "Low Blow", message: " Type in a new password.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }else{
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            
            //changeRequest. = firstLastName
            changeRequest?.commitChanges(completion: { (error) in
                if error == nil{
                    
                    let user = Auth.auth().currentUser
           
                    let userInfo = ["firstLastName": self.name,  "email": finalEmail, "password": newPassword, "location": self.locationOld, "interests": self.interestsOld, "biography": self.biog, "uid": self.uid, "photoURL": self.photoUrl]
                    
                    let userRef = self.dataBaseRef.child("users").child((user?.uid)!)
                    userRef.setValue(userInfo)
                    
                    print("user info set")
                    
                    
                    user?.updatePassword(to: newPassword!) { error in
                        if let error = error {
                            print(error)
                            
                            
                            let credential = EmailAuthProvider.credential(withEmail: finalEmail, password: newPassword!)
                            
                            user?.reauthenticate(with: credential) { error in
                                if let error = error {
                                    
                                    print(error)
                                    // An error happened.
                                } else {
                                    print("AUTHENTICATED")
                                    // User re-authenticated.
                                }
                            }
                            
                        } else {
                            
                        }
                    }
                    
                }else{
                    print(error?.localizedDescription)
                }
            })
            self.view.endEditing(true)
            showAlert(message: "Password changed.")
            
        }}
    
    @IBAction func updateLocation(_ sender: Any) {
        
        let zipCode = location.text
       
        getLocationFromPostalCode(postalCode: zipCode!) { (location) in
            guard let locationNew = location else {
              
                let alertController = UIAlertController(title: "Low Blow", message: " Input a new zip code.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                print("no location")
                return
            }
          
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.commitChanges(completion: { (error) in
                if error == nil{
                    
                    let user = Auth.auth().currentUser
                    
                    let userInfo = ["firstLastName": self.name,  "email": self.emailString, "password": self.passwordOld, "location": locationNew, "interests": self.interestsOld, "biography": self.biog, "uid": self.uid, "photoURL": self.photoUrl]
                    
                    let userRef = self.dataBaseRef.child("users").child((user?.uid)!)
                    userRef.setValue(userInfo)
                    
                    print("user info set")
                    
                }
                
                
            })
            self.view.endEditing(true)
         self.showAlert(message: "Location changed.")
        }
      
    }
        
    
    
    func getLocationFromPostalCode(postalCode : String, completion:@escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(postalCode) {
            (placemarks, error) -> Void in
            // Placemarks is an optional array of type CLPlacemarks, first item in array is best guess of Address
            
            if let placemark = placemarks?.first {
                
                if placemark.postalCode == postalCode {
                    // you can get all the details of place here
                    print("\(placemark.locality)")
                    print("\(placemark.country)")
                    completion(placemark.locality)
                    return
                }
                else{
                    print("Please enter valid zipcode")
                }
            }
            completion(nil)
            
        }
    }
    
    
    @IBAction func updateEmailAction(_ sender: Any) {
      
        var pictureD: Data? = nil
        if let imageView = self.profileImage.image{
            pictureD = UIImageJPEGRepresentation(imageView, 0.70)
        }
        
        let emailField = emailText.text?.lowercased()
        let finalEmail = emailField?.trimmingCharacters(in: .whitespacesAndNewlines)
      
        if  (finalEmail?.isEmpty)! {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "Low Blow", message: " Type in a new Email.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }else{
  
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()

            //changeRequest. = firstLastName
            changeRequest?.commitChanges(completion: { (error) in
                        if error == nil{
                            
                            let user = Auth.auth().currentUser

                            let userInfo = ["firstLastName": self.name,  "email": finalEmail, "password": self.passwordOld, "location": self.locationOld, "interests": self.interestsOld, "biography": self.biog, "uid": self.uid, "photoURL": self.photoUrl]
                            
                            let userRef = self.dataBaseRef.child("users").child((user?.uid)!)
                            userRef.setValue(userInfo)
                            
                            print("user info set")
                            
                            user?.updateEmail(to: finalEmail!) { error in
                                if let error = error {
                                    print(error)
                                    
                                    
                                    let credential = EmailAuthProvider.credential(withEmail: finalEmail!, password: self.passwordOld)
                                    
                                    user?.reauthenticate(with: credential) { error in
                                        if let error = error {
                                            
                                            print(error)
                                            // An error happened.
                                        } else {
                                            print("AUTHENTICATED")
                                            // User re-authenticated.
                                        }
                                    }
                                    
                                } else {
                                    
                                }
                            }
                            
                        }else{
                            print(error?.localizedDescription)
                        }
                    })
            self.view.endEditing(true)
showAlert(message: "Email updated.")
            
        }}
    

    @IBAction func logOutAction(_ sender: Any) {
        
        
        
        if let user = Auth.auth().currentUser {
            // there is a user signed in
            
            let fcmRef = Database.database().reference().child("FCMToken/\(user.uid)")
            
            fcmRef.setValue("REMOVE") { error, ref in
                fcmRef.removeValue() { error, ref in
                    do {
                        try? Auth.auth().signOut()
                        
                        self.performSegue(withIdentifier: "login", sender: self)
                        
                    }
                }
            }
            
            
        } else {
            self.performSegue(withIdentifier: "login", sender: self)
        }
        
    }

    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    
    var storageRef: Storage {
        
        return Storage.storage()
    }
    
    var name = String()
    var uid = String()
    var locationOld = String()
    var biog = String()
    var interestsOld = String()
   var passwordOld = String()
    var emailString = String()
    
    
    func loadUserInfo(){
        
        let userRef = dataBaseRef.child("users/\(Auth.auth().currentUser!.uid)")
        
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
          
            if let pw = user.password{
                self.passwordOld = pw
                self.password.placeholder = "******"
            }
            if let emailOld = user.email{
                self.emailText.placeholder = emailOld
                self.emailString = emailOld
            }
            if let urlPhoto = user.photoURL{
                self.photoUrl = urlPhoto
                
            }
            if let username = user.firstLastName{
                self.name = username
                self.nameTextField.placeholder = username
            }
            if let uid = user.uid{
                self.uid = uid
            }
            
            if let userLocation = user.location{
                self.locationOld = userLocation
                self.location.placeholder = "Enter new Zip Code"
            }
            if let bio = user.biography{
                self.biog = bio
            }
            if let interests = user.interests{
                self.interestsOld = interests
            }
            
            if let image = user.photoURL{
                
                
                //  let imageURL = user.photoURL!
                
                self.storageRef.reference(forURL: image).getData(maxSize: 10 * 1024 * 1024, completion: { (imgData, error) in
                    
                    if error == nil {
                        DispatchQueue.main.async {
                            if let data = imgData {
                                self.profileImage.image = UIImage(data: data)
                            }
                        }
                        
                    }else {
                        print(error!.localizedDescription)
                        
                    }
                })
                
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserInfo()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
        
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

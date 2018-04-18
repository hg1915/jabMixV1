

import UIKit
import SVProgressHUD
import CoreLocation

protocol PreferencesViewControllerDelegate: class {
    
}

class PreferencesViewController: UIViewController, BEMCheckBoxDelegate, UITextViewDelegate, UITextFieldDelegate {

    //MARK:Variables
    weak var delegate: PreferencesViewControllerDelegate?
    
    var user: UserPass?
    var authService = AuthService()
    var options = [String]()
    
    
    //MARK: Outlets
    @IBOutlet weak var pictureDataSent: UIImageView!
    
    @IBOutlet weak var sentPic: UIImageView!
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var completeButton: UIButton!
    
    @IBOutlet weak var boxing: BEMCheckBox!
    
    @IBOutlet weak var kickboxing: BEMCheckBox!
    
    @IBOutlet weak var jiujitsu: BEMCheckBox!
    
    @IBOutlet weak var karate: BEMCheckBox!
    
    
    @IBOutlet weak var judo: BEMCheckBox!
    
    @IBOutlet weak var muayThai: BEMCheckBox!
    
    
    //MARK: Actions
    @IBAction func completeButtonAction(_ sender: Any) {
        submitPressed()
    }

    @IBAction func showInterests(_ sender: Any) {
        print(options.joined(separator: " , "))
        user?.interests = options.joined(separator: ", ")
        print(user?.interests)
    }
    
    //MARK: Overrides
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        
        sentPic.image = user?.image
        print(user?.name)
        print(user?.email)
        print(user?.pass)
        print(user?.zipCode)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "SIGNUP"
        
        //        completeButton.layer.borderWidth = 1
        //        completeButton.layer.borderColor = UIColor.white.cgColor
        //
        boxing.delegate = self
        kickboxing.delegate = self
        jiujitsu.delegate = self
        karate.delegate = self
        judo.delegate = self
        muayThai.delegate = self
        bioTextView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getLocationFromPostalCode(postalCode : String, completion:@escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(postalCode) {
            (placemarks, error) -> Void in
            // Placemarks is an optional array of type CLPlacemarks, first item in array is best guess of Address
            
            if let placemark = placemarks?.first {
                
                if placemark.postalCode == postalCode {
                    // you can get all the details of place here
                    print("\(String(describing: placemark.locality))")
                    print("\(String(describing: placemark.country))")
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

    
    func submitPressed(){
        guard let user = self.user else { return }
        
        var pictureD: Data? = nil
        
        if let imageView = self.sentPic.image{
            pictureD = UIImageJPEGRepresentation(imageView, 0.3)
        }
        let nameText = user.name!
        let interests = options.joined(separator: ", ")
        
        let emailField = user.email!.lowercased()
        let finalEmail = emailField.trimmingCharacters(in: .whitespacesAndNewlines)
        let biography = bioTextView.text!
        let passwordText = user.pass
        if  finalEmail.isEmpty || biography.isEmpty || user.pass!.isEmpty || interests.isEmpty || pictureD == nil {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "Low Blow", message: " You must fill all the fields.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }else {
            
             SVProgressHUD.show()
            getLocationFromPostalCode(postalCode: user.zipCode!) { (location) in
                self.view.endEditing(true)
                self.authService.signUP(firstLastName: nameText, email: finalEmail, location: location ?? "Unknown", biography: biography, password: user.pass!, interests: interests, pictureData: pictureD! as NSData)
               
            }

        }
         SVProgressHUD.dismiss()
   
    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (bioTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 100
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        switch checkBox {
        case kickboxing:
            addRemoveOption(forState: checkBox.on, option: "Kickboxing")
        case jiujitsu :
            addRemoveOption(forState: checkBox.on, option: "Jiujitsu")
        case karate:
            addRemoveOption(forState: checkBox.on, option: "MMA")
        case judo :
            addRemoveOption(forState: checkBox.on, option: "Basic Self Defense")
        case muayThai:
            addRemoveOption(forState: checkBox.on, option: "Muay Thai")
//        case capoeira :
//            addRemoveOption(forState: checkBox.on, option: "Capoeira")
//        case aikido:
//            addRemoveOption(forState: checkBox.on, option: "Aikido")
//        case wrestling :
//            addRemoveOption(forState: checkBox.on, option: "Wrestling")
//        case hapkido:
//            addRemoveOption(forState: checkBox.on, option: "Hapkido")
//        case wingChun :
//            addRemoveOption(forState: checkBox.on, option: "Wingchun")
//        case taekwondo :
//            addRemoveOption(forState: checkBox.on, option: "Taekwondo")
        case boxing :
            addRemoveOption(forState: checkBox.on, option: "Boxing")
        default:
            addRemoveOption(forState: checkBox.on, option: "Boxing")
        }
        
    }
    
    
    func addRemoveOption(forState : Bool , option : String)
    {
        switch forState
        {
        case true:
            options += [option]
        case false:
            if let index = options.index(of: option)
            {
                options.remove(at: index)
            }
            
        }
    }


}

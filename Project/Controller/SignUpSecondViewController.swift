

import UIKit
import SVProgressHUD
import CoreLocation

class SignUpSecondViewController: UIViewController, BEMCheckBoxDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var pictureDataSent: UIImageView!
    
    @IBOutlet weak var sentPic: UIImageView!
    
    var name = String()
    var email = String()
    var password = String()
    var pictureData = UIImage()
    var interests = String()
    var zipCode = String()
    var zipLoca = String()
    
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
    


    
    @IBOutlet weak var bioTextView: UITextView!
    
    
    var authService = AuthService()
    

    
    func submitPressed(){
        
        var pictureD: Data? = nil
        if let imageView = self.sentPic.image{
            pictureD = UIImageJPEGRepresentation(imageView, 0.2)
        }
        let nameText = name
        let interests = options.joined(separator: ", ")
        
        let emailField = email.lowercased()
        let finalEmail = emailField.trimmingCharacters(in: .whitespacesAndNewlines)
        let biography = bioTextView.text!
        let passwordText = password
        if  finalEmail.isEmpty || biography.isEmpty || password.isEmpty || interests.isEmpty || pictureD == nil {
            self.view.endEditing(true)
            let alertController = UIAlertController(title: "Low Blow", message: " You must fill all the fields.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }else {
            
             SVProgressHUD.show()
            print("WAD")
            getLocationFromPostalCode(postalCode: zipCode) { (location) in
//                guard let location = location else {
//                    print("no location")
//                    return
//                }
//
               
                
                self.view.endEditing(true)
                self.authService.signUP(firstLastName: nameText, email: finalEmail, location: location ?? "Unknown", biography: biography, password: self.password, interests: interests, pictureData: pictureD! as NSData)
               
            }
        }
         SVProgressHUD.dismiss()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewTabBarViewController") as! UIViewController
        // Alternative way to present the new view controller
        //self.navigationController?.present(vc, animated: true, completion: nil)
    }
        

    @IBAction func completeButtonAction(_ sender: Any) {
       
        
        submitPressed()
        

    }
    @IBOutlet weak var completeButton: UIButton!

    @IBOutlet weak var boxing: BEMCheckBox!
    
    @IBOutlet weak var kickboxing: BEMCheckBox!
    
    
    @IBOutlet weak var jiujitsu: BEMCheckBox!
    
    
    @IBOutlet weak var karate: BEMCheckBox!
    
    
    @IBOutlet weak var judo: BEMCheckBox!
    
    @IBOutlet weak var muayThai: BEMCheckBox!
    
    
 
  
    @IBAction func showInterests(_ sender: Any) {
        print(options.joined(separator: " , "))
        interests = options.joined(separator: ", ")
        print(interests)
    }
    
  
   
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
       
      sentPic.image = pictureData
        print(name)
        print(email)
        print(password)
        print(zipCode)
        print(zipLoca)
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

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (bioTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 100
    }
    
    var options = [String]()
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

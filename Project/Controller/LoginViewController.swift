
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var nameText: DesignableUITextField!
    @IBOutlet weak var emailText: DesignableUITextField!
    @IBOutlet weak var passwordText: DesignableUITextField!
    @IBOutlet weak var zipCodeInput: DesignableUITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpOutlet: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!{
        didSet{
            userImageView.layer.cornerRadius = 5
            userImageView.isUserInteractionEnabled = true
        }
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        userImageView.layer.borderWidth = 0
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
   
            
       self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        setGestureRecognizersToDismissKeyboard()
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        signUp()
    }
    
    
    
    func showAlert(message : String) -> Void {
        let alert = UIAlertController(title: "Low Blow!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
 
    func signUp(){
        if userImageView.image == nil{
            showAlert(message: "Please set your profile photo")
        }
        else if nameText.text == "" {
            showAlert(message: "Please enter your name.")
            
        }else if (nameText.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            showAlert(message: "Please enter a valid name.")
        }
        else if emailText.text == "" {
            showAlert(message: "Please enter a valid email.")
        }else if isValid(emailText.text!) != true{
            showAlert(message: "Please enter a valid email.")
        }
            
        else if passwordText.text == ""{
            showAlert(message: "Please enter a password.")
        }
            
        else if (passwordText.text?.characters.count)! < 6{
            showAlert(message: "Password should be greater than 6 characters.")
        }
            
        else if zipCodeInput.text == "" {
            showAlert(message: "Please enter your zip code.")
        }else if (zipCodeInput.text?.characters.count)! != 5{
            showAlert(message: "Please enter a valid zip code")
        }
        else{
            performSegue(withIdentifier: "toSecondView", sender: self)
        }
        
    }
  
    
    
    
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
 
    
    
    
    

    

    
    func setUpButtons(){
        loginButtonOutlet.layer.borderWidth = 1
        loginButtonOutlet.layer.borderColor = UIColor.white.cgColor
        signUpOutlet.layer.borderWidth = 1
        signUpOutlet.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
 
        if let destination = segue.destination as? SignUpSecondViewController{
          
        destination.zipCode = zipCodeInput.text! 
        destination.name = nameText.text!
        destination.email = emailText.text!
        destination.password = passwordText.text!
        destination.pictureData = userImageView.image!
        }}
        
    }


extension LoginViewController:UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setGestureRecognizersToDismissKeyboard(){
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.choosePictureAction(sender:)))
        imageTapGesture.numberOfTapsRequired = 1
        userImageView.addGestureRecognizer(imageTapGesture)
    }

    @objc func choosePictureAction(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Profile Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage{
            self.userImageView.image = image
        }else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.userImageView.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
  
}







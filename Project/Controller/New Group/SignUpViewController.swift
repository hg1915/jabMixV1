
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

protocol SignUpViewControllerDelegate: class{
    func signUpButtonPressed(_ viewcontroller: UIViewController, user: UserPass)
    func loginButtonPressed(_ viewcontroller: UIViewController)
    
}

struct UserPass{
    var name: String? = ""
    var email: String? = ""
    var pass: String? = ""
    var zipCode: String? = ""
    var interests: String? = ""
    var image: UIImage? = nil
}

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Delegates
    var delegate: SignUpViewControllerDelegate?
    
    //MARK: Outlets
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
    
    //MARK: Actions
    @IBAction func signUpButton(_ sender: Any) {
        signUp()
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        delegate?.loginButtonPressed(self)
    }
    
    //MARK: Overrides
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
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    //    {
    //
    //        if let destination = segue.destination as? SignUpSecondViewController{
    //
    //            destination.zipCode = zipCodeInput.text!
    //            destination.name = nameText.text!
    //            destination.email = emailText.text!
    //            destination.password = passwordText.text!
    //            destination.pictureData = userImageView.image!
    //        }}
    
    
    
    
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
            signUpButtonPressed()
//            performSegue(withIdentifier: "toSecondView", sender: self)
        }
        
    }
    
    func signUpButtonPressed(){
        
        delegate?.signUpButtonPressed(self, user: updateUserInfo())
    }
    
    func updateUserInfo()-> UserPass{
        var user = UserPass()
        
        user.zipCode = zipCodeInput.text!
        user.name = nameText.text!
        user.email = emailText.text!
        user.pass = passwordText.text!
        user.image = userImageView.image!
        return user
    }
    
    
    func setUpButtons(){
        loginButtonOutlet.layer.borderWidth = 1
        loginButtonOutlet.layer.borderColor = UIColor.white.cgColor
        signUpOutlet.layer.borderWidth = 1
        signUpOutlet.layer.borderColor = UIColor.white.cgColor
        
    }
    
}



extension SignUpViewController:UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setGestureRecognizersToDismissKeyboard(){
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.choosePictureAction(sender:)))
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







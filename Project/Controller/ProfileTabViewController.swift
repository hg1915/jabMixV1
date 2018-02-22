

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Firebase

class ProfileTabViewController: UIViewController {


    
    @IBOutlet weak var biog: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
var authService = AuthService()
    
    @IBOutlet weak var interests: UILabel!
    

    
    var user: User!
    
    var dataBaseRef: DatabaseReference!{
        return Database.database().reference()
    }
    var storageRef: StorageReference!{
        return Storage.storage().reference()
    }
 
    func updatePhoto() {
        
    let user = Auth.auth().currentUser
        
        let newPhoto = profileImage.image
        
        let imgData = UIImageJPEGRepresentation(newPhoto!, 0.7)!
  
    
        let imagePath: String = "profileImage\(user!.uid)/userPic.jpg"
       
       
        
        let imageRef = storageRef.child(imagePath)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(imgData as Data, metadata: metaData){(newMetaData, error)
            in
            if error == nil{
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                if let photoURL = newMetaData!.downloadURL(){
                    changeRequest?.photoURL = photoURL
                    
                changeRequest?.commitChanges(completion: { (error) in
                    if error == nil{
                        let user = Auth.auth().currentUser
                        let userInfo = ["firstLastName": self.nameOld,  "email": user?.email, "password": self.passwordOld, "location": self.locationOld, "interests": self.interestsOld, "biography": self.bioOld, "uid": user?.uid, "photoURL": photoURL.absoluteString]
                        
                        let userRef = self.dataBaseRef.child("users").child((user?.uid)!)
                        userRef.setValue(userInfo)
                        
                    }
                    
                    print("user info set")
                    
                    })
                }
        
            }
        

        
        
        }
    }
    
    var storageR: Storage {
        
        return Storage.storage()
    }
    func loadUserInfo(){
        
        
        let userRef = dataBaseRef.child("users/\(Auth.auth().currentUser!.uid)")
        
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            
            if let username = user.firstLastName{
                self.name.text = username
                self.nameOld = username
            }
            
            if let pass = user.password{
                self.passwordOld = pass
            }
            
            if let userLocation = user.location{
                self.location.text = userLocation
                self.locationOld = userLocation
            }
            if let bio = user.biography{
                self.biog.text = bio
                self.bioOld = bio
            }
            if let interests = user.interests{
                self.interests.text = interests
                self.interestsOld = interests 
            }
            
            if let imageOld = user.photoURL{
                
                
                //  let imageURL = user.photoURL!
                
            
                
                self.storageR.reference(forURL: imageOld).getData(maxSize: 10 * 1024 * 1024, completion: { (imgData, error) in
                    
                    if error == nil {
                        DispatchQueue.main.async {
                            if let data = imgData {
                                self.profileImage.image = UIImage(data: data)
                            }
                        }
                        
                    }else {
                        print(error!.localizedDescription)
                        
                    }
                    
                }
                    
                    
                )}
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    

    var nameOld = String()
    var uid = String()
    var locationOld = String()
    var bioOld = String()
    var interestsOld = String()
    var passwordOld = String()
    var emailString = String()
    var photoUrlOld = String()
        
    override func viewWillAppear(_ animated: Bool) {
        loadUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        
        
 
        profileImage.layer.borderWidth = 1
     //   profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
      //  profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
//        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "PROFILE"
        
        setGestureRecognizersToDismissKeyboard()
      //  loadUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}


extension ProfileTabViewController:UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    
    
    func setGestureRecognizersToDismissKeyboard(){
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileTabViewController.choosePictureAction(sender:)))
        imageTapGesture.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(imageTapGesture)
        
      
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
            self.profileImage.image = image
            updatePhoto()
            loadUserInfo()
        }
        else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImage.image = image
            updatePhoto()
            loadUserInfo()
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
}

extension UIImageView {
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
        self.image = anyImage
    }
}


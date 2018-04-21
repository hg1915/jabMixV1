

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Firebase

class ProfileTabViewController: UIViewController {
    
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    @IBOutlet weak var biog: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var interests: UILabel!
    
    
    let addImagesViewModel = AddImagesViewModel()
    let authService = AuthService()
    
    var user: User!
    var imageType: UserUpdate? = UserUpdate.profileImage
    var dataBaseRef: DatabaseReference!{
        return Database.database().reference()
    }
    var storageRef: StorageReference!{
        return Storage.storage().reference()
    }
    
    
    var nameOld = String()
    var uid = String()
    var locationOld = String()
    var bioOld = String()
    var interestsOld = String()
    var passwordOld = String()
    var emailString = String()
    var photoUrlOld = String()
    
    func updatePhoto(type: UserUpdate, image: UIImage) {
        
        if let user = Auth.auth().currentUser{
            
            updateUserSingleProperty(user: user, type: type, stringValue: nil, imageValue: image, completion: { done in
                if done{
                    self.createAlert(title: "Image", message: "Image uploaded!")
                    self.imagesCollectionView.reloadData()
                } else {
                    self.createAlert(title: "Error", message: "Image failed upload!")
                }
            })
            
        }
        
    }
    
    var storageR: Storage {
        
        return Storage.storage()
    }
    
    func loadUserInfo(){
        
        let dataBaseRef: DatabaseReference = {
            return Database.database().reference()
        }()
        
        let user = Auth.auth().currentUser!
        
        let userRef = dataBaseRef.child("users/\(user.uid)")
        
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
            
//            if let images = user.images{
//                self.addImagesViewModel.images.removeAll()
//                for image in images{
//
//                    self.addImagesViewModel.images.append(image.value)
//                }
//            }
            
            if let imageOld = user.photoURL{
                
                if !imageOld.isEmpty{
                    
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
                        
                        
                    )
                }
                
                
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addImagesViewModel.viewController = self
        
        self.imagesCollectionView.register(AddImagesCell.nib, forCellWithReuseIdentifier: AddImagesCell.identifier)
        self.imagesCollectionView.delegate = addImagesViewModel
        self.imagesCollectionView.dataSource = addImagesViewModel
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.clipsToBounds = true
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "PROFILE"
        
        setGestureRecognizersToDismissKeyboard()
        //  loadUserInfo()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCollectionView), name: .reloadProfileCollectionView, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addImagesViewModel.loadImages()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadCollectionView(){
        self.imagesCollectionView.reloadData()
    }
    
    
    
}


extension ProfileTabViewController:UIPickerViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    
    
    func setGestureRecognizersToDismissKeyboard(){
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileTabViewController.choosePictureAction))
        imageTapGesture.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(imageTapGesture)
        
        
    }
    
    
    
    @objc func choosePictureAction() {
        
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
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            if imageType == UserUpdate.profileImage{
                self.profileImage.image = image
                updatePhoto(type: .profileImage, image: image)
                loadUserInfo()
            } else {
                if let type = self.imageType{
                    
                    updatePhoto(type: type, image: image)
                    loadUserInfo()
                }
            }
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



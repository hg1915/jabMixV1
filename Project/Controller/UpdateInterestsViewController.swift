//
//  UpdateInterestsViewController.swift
//  jabMix1
//
//  Created by HG on 1/7/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UpdateInterestsViewController: UIViewController, BEMCheckBoxDelegate, UITextViewDelegate, UITextFieldDelegate {

    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    var authService = AuthService()
    
    
    @IBOutlet weak var boxing: BEMCheckBox!
    
    @IBOutlet weak var kickboxing: BEMCheckBox!
    
    @IBOutlet weak var jiujitsu: BEMCheckBox!
    
    
    @IBOutlet weak var karate: BEMCheckBox!
    
    
    @IBOutlet weak var judo: BEMCheckBox!
    
    
    @IBOutlet weak var muayThai: BEMCheckBox!
    
 
    @IBOutlet weak var bioTextView: UITextView!
    
    
    @IBOutlet weak var updateButton: UIButton!
    
    
    
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
     var photoUrl = String()
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserInfo()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = "INTERESTS"
    }
    func loadUserInfo(){
        
        let userRef = dataBaseRef.child("users/\(Auth.auth().currentUser!.uid)")
        
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            
            if let pw = user.password{
                self.passwordOld = pw
                
            }
            if let emailOld = user.email{
               
                self.emailString = emailOld
            }
            if let urlPhoto = user.photoURL{
                self.photoUrl = urlPhoto
                
            }
            if let username = user.firstLastName{
                self.name = username
            }
            if let uid = user.uid{
                self.uid = uid
            }
            
            if let userLocation = user.location{
                self.locationOld = userLocation
               
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
                    
                }
                    
                    
                )}
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    var newBio = String()
   
    func showAlert(message : String) -> Void {
        let alert = UIAlertController(title: "Low Blow!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
   

    func updateFunction(){
        
        let newInterests = options.joined(separator: " , ")
        
        if bioTextView.text == ""{
            newBio = self.biog
        }else{
            newBio = bioTextView.text
        }
        
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.commitChanges(completion: { (error) in
            if error == nil{
                
                let user = Auth.auth().currentUser
                
                let userInfo = ["firstLastName": self.name,  "email": self.emailString, "password": self.passwordOld, "location": self.locationOld, "interests": newInterests, "biography": self.newBio, "uid": self.uid, "photoURL": self.photoUrl]
                
                let userRef = self.dataBaseRef.child("users").child((user?.uid)!)
                userRef.setValue(userInfo)
               
                let alertController = UIAlertController(title: "Success", message: " Information successfully updated.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
           
                print("user info set")
                
            }
            
            
        })
        
        
        
        let alertController = UIAlertController(title: "Success", message: " Information successfully updated.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
    }
    
    
    @IBAction func updateAction(_ sender: Any) {
         let newInterests = options.joined(separator: " , ")
        
        if newInterests == ""{
            showAlert(message: "Please select at least one interest.")
        }else{
           updateFunction()
            print("test one")
            for controller in (self.navigationController?.viewControllers)! {
                if controller is ProfileTabViewController {
                    self.navigationController!.popToViewController(controller, animated: true)
                    dismiss(animated: true, completion: nil)
                    break
                }
        }
      
        }}
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (bioTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 100
    }
    
    var options = [String]()
    
    func didTap(_ checkBox: BEMCheckBox) {
        switch checkBox {
        case kickboxing:
            addRemoveOption(forState: checkBox.on, option: "Basic Self Defense")
        case jiujitsu :
            addRemoveOption(forState: checkBox.on, option: "Jiujitsu")
        case karate:
            addRemoveOption(forState: checkBox.on, option: "MMA")
        case judo :
            addRemoveOption(forState: checkBox.on, option: "Muay Thai")
        case muayThai:
            addRemoveOption(forState: checkBox.on, option: "Kickboxing")
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        boxing.delegate = self
        kickboxing.delegate = self
        jiujitsu.delegate = self
        karate.delegate = self
        judo.delegate = self
        muayThai.delegate = self
        bioTextView.delegate = self
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}



import UIKit
import Firebase

class ProfilePageViewController: UIViewController {

     var user:Users!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var bio: UILabel!
  
    
    
    @IBOutlet weak var interests: UILabel!
    
    @IBOutlet weak var request: UIButton!
    
    
    @IBAction func requestAction(_ sender: Any) {
    }
    
    func displayData(){
       
        
        
        interests.text = user.interests
        name.text = user.firstLastName
        bio.text = user.biography
        location.text = user.location
       //usernameLabel.text = "@\(user.username)"
        profileImage.loadImageUsingCacheWithUrlString(urlString: user.photoURL)
    }
    
    func setUpButtons(){
     
        request.layer.borderWidth = 1
        request.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
    profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        
      //  setUpButtons()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = "REQUEST"
        displayData()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        request.isEnabled = false
        
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let uid = user.uid else { return }
        let ref = Database.database().reference()
        let blockedRef = ref.child("social/blockedBy/\(currentUser.uid)/\(uid)")
        blockedRef.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("User has blocked you.")
                self.request.isEnabled = false
            } else {
                print("User has not blocked you.")
                self.request.isEnabled = true
            }
        }, withCancel: { error in
            print("Unable to retrieve.")
            self.request.isEnabled = false
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SendRequestViewController{
            destinationVC.recipientUser = user 
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

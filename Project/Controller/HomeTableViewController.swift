

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
import FirebaseAuth

class HomeTableViewController: UITableViewController {

    
    @IBOutlet var partnersTableView: UITableView!
    
    var usersArray = [Users]()
    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

      //  self.partnersTableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        
      // self.automaticallyAdjustsScrollViewInsets = false
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
     //   self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
       self.navigationController?.view.backgroundColor = UIColor.clear

        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "JABMIX"
        
        partnersTableView.delegate = self
        partnersTableView.dataSource = self
        
        
         partnersTableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "usersCell")
        
       
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchUsers()
    }
    
    
    func fetchUsers(){
        
        dataBaseRef.child("users").observe(.value, with: { (snapshot) in
            var results = [Users]()
            
            for user in snapshot.children {
                
                let user = Users(snapshot: user as! DataSnapshot)
                
                
                if user.uid != Auth.auth().currentUser?.uid{
                    
                    results.append(user)
                }
      
                
            }
            
            self.usersArray = results.sorted(by: { (u1, u2) -> Bool in
                u1.firstLastName < u2.firstLastName
            })
            self.partnersTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = partnersTableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell
       cell.configureCell(user: usersArray[indexPath.row])
        
        return cell
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destination = segue.destination as? ProfilePageViewController, let selectedRow = sender as? Int {
            destination.user = usersArray[selectedRow]
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toProfile", sender: indexPath.row)
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
        
    }

    

}

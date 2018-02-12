
import Foundation
import UIKit
import Firebase



class RequestDetailViewController:UITableViewController {
 

    @IBOutlet weak var topViewTable: UITableViewCell!
    
    @IBOutlet weak var bottomViewTable: UITableViewCell!

    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var senderUsernameLabel: UILabel!
    
    @IBOutlet weak var recipientImageView: UIImageView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var recipientUsernameLabel: UILabel!
    
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var locationCell:UITableViewCell!
//    @IBOutlet weak var whenCell:UITableViewCell!
//    @IBOutlet weak var whereCell:UITableViewCell!
    @IBOutlet weak var messageCell:UITableViewCell!
    
    @IBOutlet weak var responseStackView: UIStackView!
    @IBOutlet weak var responseLabel: UILabel!
    var request:Request!

    override func viewDidLoad() {
        
        
        self.topViewTable.isUserInteractionEnabled = false
        self.bottomViewTable.isUserInteractionEnabled = false 
  
        self.senderImageView.isUserInteractionEnabled = false
        self.senderNameLabel.isUserInteractionEnabled = false
        self.senderUsernameLabel.isUserInteractionEnabled = false
        self.recipientImageView.isUserInteractionEnabled = false
        self.recipientNameLabel.isUserInteractionEnabled = false
        self.recipientUsernameLabel.isUserInteractionEnabled = false
        self.dateCell.isUserInteractionEnabled = false
        self.locationCell.isUserInteractionEnabled = false
        self.messageCell.isUserInteractionEnabled = false
        //self.view.isUserInteractionEnabled = false
        super.viewDidLoad()
        
  
        
        self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
    }
//
//    func getCurrentDateTimeFromTimeStamp(timestamp:String)->String{
//        let date = NSDate(timeIntervalSince1970:Double(timestamp)!)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM d, yyyy HH:mm a"
//        return formatter.string(from: date as Date)
//    }
    
    func getCurrentDateTimeFromTimeStamp(timestamp:String)->String{
        let date = NSDate(timeIntervalSince1970:Double(timestamp)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy hh:mm a"
        formatter.timeZone = TimeZone(abbreviation: "PST")
        return formatter.string(from: date as Date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = Auth.auth().currentUser else { return }
        
        title = user.uid == request.sender ? "Sent Request" : "Received Request"
        
        let db = Database.database().reference()
        let senderRef = db.child("users/\(request.sender)")
        senderRef.observeSingleEvent(of: .value, with: { snapshot in
            self.setSenderInfo(Users(snapshot: snapshot))
        })
        
        let recipientRef = db.child("users/\(request.recipient)")
        recipientRef.observeSingleEvent(of: .value, with: { snapshot in
            self.setRecipientInfo(Users(snapshot: snapshot))
        })
         func getCurrentDateTimeFromTimeStamp(timestamp:String)->String{
            let date = NSDate(timeIntervalSince1970:Double(timestamp)!)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm a"
            formatter.timeZone = TimeZone(abbreviation: "PST")
            return formatter.string(from: date as Date)
        }
        
 
      //  let date = Date(timeIntervalSince1970: request.timestamp / 1000)
       
        let dateCellVar = (request.timestamp / 1000)
        let dateString = dateCellVar.description
        
        
        
        dateCell.textLabel?.text = self.getCurrentDateTimeFromTimeStamp(timestamp: dateString)
        
     //   dateCell.textLabel?.text = date.description
        dateCell.detailTextLabel?.text = "Date"
        locationCell.textLabel?.text = request.location
        locationCell.detailTextLabel?.text = "Location"
//        whenCell.textLabel?.text = request.when
//        whenCell.detailTextLabel?.text = "When"
//        whereCell.textLabel?.text = request.whereStr
//        whereCell.detailTextLabel?.text = "Where"
        
        messageCell.textLabel?.text = request.message
        messageCell.detailTextLabel?.text = "Message"
        
        setResponseButtonsEnabled(request.status == "PENDING" && user.uid == request.recipient)
        
    }
    
    func setSenderInfo(_ user:Users) {
        senderNameLabel.text = user.firstLastName
        senderUsernameLabel.text = user.firstLastName
        senderImageView.layer.cornerRadius = senderImageView.frame.height / 2
        senderImageView.clipsToBounds = true
        Storage.storage().reference(forURL: user.photoURL).getData(maxSize: 10 * 1024 * 1024) { imgData, error in
            
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.senderImageView?.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    func setRecipientInfo(_ user:Users) {
        recipientNameLabel.text = user.firstLastName
        recipientUsernameLabel.text = user.firstLastName
        recipientImageView.layer.cornerRadius = recipientImageView.frame.height / 2
        recipientImageView.clipsToBounds = true
        
        Storage.storage().reference(forURL: user.photoURL).getData(maxSize: 10 * 1024 * 1024) { imgData, error in
            
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.recipientImageView?.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    @IBAction func handleAcceptButton(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Database.database().reference()
        let ref = db.child("requests/\(request.key)/status")
        request.status = "ACCEPTED"
        ref.setValue(request.status)
        setResponseButtonsEnabled(false)
    }
    
    @IBAction func handleDenyButton(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Database.database().reference()
        let ref = db.child("requests/\(request.key)/status")
        request.status = "DENIED"
        ref.setValue(request.status)
        setResponseButtonsEnabled(false)
    }
    
    func setResponseButtonsEnabled(_ enabled:Bool) {
        print("setResponseButtonsEnabled")
        responseStackView.isHidden = !enabled
        responseLabel.isHidden = enabled
        responseLabel.text = request.status
    }
    
}



import UIKit
import GooglePlaces
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UIColor_Hex_Swift

class SendRequestViewController: UIViewController, UITextViewDelegate {
 @IBOutlet weak var locationField: DesignableUITextField!
   
    
    @IBOutlet weak var requestButton: UIButton!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    var recipientUser:Users!
     var user:Users!
    
    var pickedDate:Date?
    
    func displayData(){
        
        
        nameLabel.text = user.firstLastName
//        interests.text = user.interests
//        name.text = user.firstLastName
//        bio.text = user.biography
//        location.text = user.location
//        //usernameLabel.text = "@\(user.username)"
//        profileImage.loadImageUsingCacheWithUrlString(urlString: user.photoURL)
    }
    
    
    
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBAction func chooseLocation(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
       
        autocompleteController.delegate = self
        
        autocompleteController.tableCellBackgroundColor = UIColor("#D8D8D8")
        autocompleteController.tintColor = UIColor("#D8D8D8")
        
        present(autocompleteController, animated: true, completion: nil)
        
    }
    @IBOutlet weak var dateField: DesignableUITextField!
    
    @IBOutlet weak var timeField: DesignableUITextField!

    func showAlert(message : String) -> Void {
        let alert = UIAlertController(title: "Low Blow!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendRequest(){
        print("HEY:")
        guard let user = currentUser else { return }
        print("USER: \(user.firstLastName)")
        
        if (dateField.text?.isEmpty)! || (locationField.text?.isEmpty)! || messageTextView.text.isEmpty{
         showAlert(message: "Please fill in all the fields!")
        }else{
//
//
//        if let da = dateField.text{
//            print(da)
//        }
        print(timeField.text)
        
        print(locationField.text)
        print(messageTextView.text)
        
        guard let pickedDate = pickedDate else { return print("pickedDate") }
        guard let date = dateField.text else { return print("pickedDate") }
        guard let time = timeField.text else { return print("time") }
        guard let location = locationField.text else { return print("location")}
        
        let db = Database.database().reference()
        let ref = db.child("requests").childByAutoId()
        let data = [
            "sender": user.uid,
            "recipient": recipientUser.uid,
            "name": user.firstLastName,
            "photoURL": user.photoURL,
            "location": location,
            "date": date,
            "time": time,
            "pickedTimestamp": pickedDate.timeIntervalSince1970,
            "message": messageTextView.text ?? "",
            "status": "PENDING",
            "timestamp": [".sv": "timestamp"]
            ] as [String:Any]
        
        print("HEYO")
        ref.setValue(data) { error, ref in
            if error == nil {
                print("Success")
            } else {
                print("Failed")
            }
        }
        }
        
    }
    
    
    @IBAction func sendRequestAction(_ sender: Any) {
       sendRequest()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewTabBarViewController") as! UIViewController
        // Alternative way to present the new view controller
        self.navigationController?.present(vc, animated: true, completion: nil)

        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (messageTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 100
    }
    
    func setUpButtons(){
        requestButton.layer.borderWidth = 1
        requestButton.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewDidLoad() {
        messageTextView.delegate = self
        super.viewDidLoad()
      //  setUpButtons()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       self.navigationItem.title = "SEND REQUEST"
        //loadUserInfo()
        createDatePicker()
        
    }

    let picker = UIDatePicker()
    func createDatePicker(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
       
        toolbar.setItems([done], animated: false)
        
        dateField.inputAccessoryView = toolbar
        dateField.inputView = picker
        picker.datePickerMode = .dateAndTime
        
    }
    
    @objc func donePressed(){
        pickedDate = picker.date
        let formatter = DateFormatter()
        // MMMddyyyy is essentially the same as the "medium" format
        formatter.setLocalizedDateFormatFromTemplate("MMMddyyyyEEE")
        let dateString = formatter.string(from: picker.date)
        
        dateField.text = "\(dateString)"
        showTime()
        self.view.endEditing(true)
    }
    var time = String()
    func showTime(){
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = DateFormatter.Style.short
        timeField.text = formatter.string(from: picker.date)
       
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func timePickerValueChanged(sender: UIDatePicker){
        pickedDate = sender.date
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.none
        formatter.timeStyle = DateFormatter.Style.short
        timeField.text = formatter.string(from: sender.date)
        
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        pickedDate = sender.date
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        dateField.text = formatter.string(from: sender.date)
   
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    
    
    
}

extension SendRequestViewController: GMSAutocompleteViewControllerDelegate{
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
     
       // placeLabel.text = ((place.name) + ", " + (place.formattedAddress)!)
        
        locationField.text = (place.formattedAddress)
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
    var dataBaseRef: DatabaseReference! {
        return Database.database().reference()
    }
    
    var storageRef: Storage {
        
        return Storage.storage()
    }
    
    
    func loadUserInfo(){
        
        
        let userRef = dataBaseRef.child("users/\(Auth.auth().currentUser!.uid)")
        
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            
            if let username = user.firstLastName{
                self.nameLabel.text = username
            }
          
            
        
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    
    
    
    
    
    
}


extension NSDate {
    // returns weekday name (Sunday-Saturday) as String
    var weekdayName: String {
        let formatter = DateFormatter(); formatter.dateFormat = "EEEE"
        return formatter.string(from: self as Date)
    }
}



















import Foundation
import UIKit
import JSQMessagesViewController
import Firebase
import Photos
import ImageIO
import SKPhotoBrowser
import UIColor_Hex_Swift

class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if(message.isMediaMessage) {
            let mediaItem =  message.media
            if mediaItem is JSQPhotoMediaItem{
                let photoItem = mediaItem as! JSQPhotoMediaItem
                if(photoItem.image != nil) {
                    var images = [SKPhoto]()
                    let photo = SKPhoto.photoWithImage(photoItem.image)
                    images.append(photo)
                    let browser = SKPhotoBrowser(photos: images)
                    browser.initializePageIndex(0)
                    present(browser, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    
    let incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).incomingMessagesBubbleImage(with: UIColor.white)
        
        
      //  (white: 0.90, alpha: 1.0))
    let incomingBubbleWithTail = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(white: 0.90, alpha: 1.0))
    
    
    
    let outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero).outgoingMessagesBubbleImage(with: UIColor.darkGray)
    let outgoingBubbleWithTail = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.darkGray)

    var messages:[JSQMessage]!

    var conversation:Conversation!
    var conversationKey:String!
    var partner:Users!
    var partnerImage:UIImage?

    var downloadRef:DatabaseReference?

    private var updatedMessageRefHandle: DatabaseHandle?
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://jabmix-162f2.appspot.com")
    private let imageURLNotSetKey = "NOTSET"
    
    @objc func handleUploadTap(){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        print("image tapped")
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        handleUploadTap()
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            
            let mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem?.appliesMediaViewMaskAsOutgoing = true
            mediaItem?.image = UIImage(data: UIImageJPEGRepresentation(selectedImage, 0.5)!)
            let sendMessage = JSQMessage(senderId: senderId, displayName: self.senderId, media: mediaItem)
            self.messages.append(sendMessage!)
            self.finishSendingMessage()
            let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL
            uploadToFirebaseStorageUsingImage(image: selectedImage, refurl: photoReferenceUrl!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage, refurl: URL){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.3){

            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in

                if error != nil {
                    print("failed to load:", error)
                    return
                }

                
                if let imageUrl = self.storageRef.child((metadata?.path)!).description as! String! {

                    self.sendMessageWithImageUrl(imageUrl: imageUrl, ref: refurl)
                }
            })}}

    
    

    private func sendMessageWithImageUrl(imageUrl: String, ref: URL){

        guard let user = currentUser else { return }
        let ref = Database.database().reference().child("conversations/threads/\(conversation.key)").childByAutoId()
        let messageObject = [
            "text":"",
            "recipient": conversation.partner_uid,
            "sender":user.uid,
            "senderName": user.firstLastName,
            "imageUrl":imageUrl,
            "timestamp": [".sv":"timestamp"]
            ] as [String:Any]
        ref.setValue(messageObject, withCompletionBlock: { error, ref in

        })

        return self.finishSendingMessage(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: self, action: #selector(handleDismiss))
        view.backgroundColor = UIColor.lightGray
        //(white: 1.0, alpha: 1.0)

        self.senderDisplayName = ""
        if let user = Auth.auth().currentUser {
            self.senderId = user.uid
        } else {
            self.senderId = ""
        }

        messages = [JSQMessage]()

        
        self.inputToolbar.contentView?.textView?.font = UIFont(name: "Lucida Grande", size: 16)!
        
        self.inputToolbar.contentView.backgroundColor = UIColor("#D8D8D8")
        
     //   self.inputToolbar.contentView.backgroundColor = UIColor.blue
//        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor.red, for: .normal)
       // self.inputToolbar.contentView.leftBarButtonItemWidth = 0
       
      //  self.inputToolbar.contentView.textView.text.
        self.inputToolbar.preferredDefaultHeight = 45
        self.inputToolbar.contentView.textView.placeHolder = ""
        self.inputToolbar.contentView.textView.keyboardAppearance = .light
//        self.inputToolbar.contentView.textView.textAlignment = NSTextAlignment(rawValue: 20)!
      
        //collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 32, height: 32)
collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
//
//        // Swift
//        if #available(iOS 11.0, *){
//            self.collectionView?.contentInsetAdjustmentBehavior = .never
//            self.collectionView?.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
//            self.collectionView?.scrollIndicatorInsets = self.collectionView.contentInset
//        }

      //  collectionView?.collectionViewLayout.springinessEnabled = true
        collectionView?.backgroundColor = UIColor("#D8D8D8")
        collectionView?.reloadData()

          title = partner.firstLastName.capitalized
        conversation.printAll()
        downloadRef = Database.database().reference().child("conversations/threads/\(conversation.key)")
        downloadMessages()


        let imageWidth: CGFloat = 40
        let image = UIImage(named: "attachmentsIcon")
        
        inputToolbar.contentView.leftBarButtonItemWidth = imageWidth
        inputToolbar.contentView.leftBarButtonItem.setImage(image, for: .normal)

        let rightImageWidth: CGFloat = 45
        let rightImage = UIImage(named: "sendIcon")
        inputToolbar.contentView.rightBarButtonItemWidth = rightImageWidth
        inputToolbar.contentView.rightBarButtonItem.setImage(rightImage, for: .normal)
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        conversation.printAll()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        downloadRef?.removeAllObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }


    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return nil
        default:
            if partnerImage != nil {
                let image = JSQMessagesAvatarImageFactory.avatarImage(with: partnerImage!, diameter: 48)
                return image
            }

            return nil
        }
    }


    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell

        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            cell.textView?.textColor = UIColor.white
        default:
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }

    override func collectionView
        
        (_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let currentItem = self.messages[indexPath.item]
        
        if indexPath.item == 0 && messages.count > 8 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: currentItem.date)
        }
        
        
        if indexPath.item > 0 {
            let prevItem    = self.messages[indexPath.item-1]
            
            let gap = currentItem.date.timeIntervalSince(prevItem.date)
            
            if gap > 1800 {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: currentItem.date)
            }
        } else {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: currentItem.date)
        }
        
        
        return nil
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item == 0 && messages.count > 8 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        if indexPath.item > 0 {
            let currentItem = self.messages[indexPath.item]
            let prevItem    = self.messages[indexPath.item-1]
            
            let gap = currentItem.date.timeIntervalSince(prevItem.date)
            
            if gap > 1800 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
            
            if prevItem.senderId != currentItem.senderId {
                return 1.0
            } else {
                return 0.0
            }
        }  else {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            break
        default:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ProfilePageViewController") as! ProfilePageViewController
            controller.user = partner
            self.navigationController?.pushViewController(controller, animated: true)
            break
        }
    }


    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard let user = currentUser else { return }
        let ref = Database.database().reference().child("conversations/threads/\(conversation.key)").childByAutoId()
        let messageObject = [
            "recipient": conversation.partner_uid,
            "sender":user.uid,
            "senderName": user.firstLastName,
            "text":text,
            "timestamp": [".sv":"timestamp"]
        ] as [String:Any]
        ref.setValue(messageObject, withCompletionBlock: { error, ref in

        })

        return self.finishSendingMessage(animated: true)
    }

    func downloadMessages() {

        self.messages = []

        downloadRef?.observe(.childAdded, with: { snapshot in
            let dict = snapshot.value as! [String:AnyObject]

            

            if let sender = dict["sender"] as! String!, let recipient = dict["recipient"] as! String!, let text = dict["text"] as! String!, text.characters.count > 0 {
                
                let timestamp = dict["timestamp"] as! Double
                
                let date = NSDate(timeIntervalSince1970: timestamp/1000)
                
                let message = JSQMessage(senderId: sender, senderDisplayName: "", date: date as Date!, text: text)
                self.messages.append(message!)
                self.reloadMessagesView()
                self.finishReceivingMessage(animated: true)
            }
            else if let id = dict["sender"] as! String!,
                let photoURL = dict["imageUrl"] as! String!, photoURL.characters.count > 0 { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    let timestamp = dict["timestamp"] as! Double
                    
                    let date = NSDate(timeIntervalSince1970: timestamp/1000)
                    
                    if let message = JSQMessage(senderId: id, senderDisplayName: "", date: date as Date!, media: mediaItem) {
                        self.messages.append(message)
                        
                        if (mediaItem.image == nil) {
                            self.photoMessageMap[snapshot.key] = mediaItem
                        }
                        self.collectionView.reloadData()
                    }
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            }
            else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        updatedMessageRefHandle = downloadRef?.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
           guard let messageData = snapshot.value as? Dictionary<String, String> else { return }
            if let photoURL = messageData["imageUrl"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
        
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        
        let storageRef = Storage.storage().reference(forURL: photoURL)

        // 2
        storageRef.getData(maxSize: INT64_MAX) { (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gifWithData(data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                self.scrollToBottom(animated: true)
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }

    func reloadMessagesView() {
        self.collectionView?.reloadData()

        guard let user = Auth.auth().currentUser else{ return }
        
        let ref = Database.database().reference().child("conversations/users/\(user.uid)/\(conversation.partner_uid)/seen")
        ref.setValue(true)
        
    }

}



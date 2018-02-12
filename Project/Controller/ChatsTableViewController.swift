//
//  ChatsTableViewController.swift
//  jabMix1
//
//  Created by Robert Canton on 2018-01-21.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Conversation {
    var key:String
    var sender:String
    var recipient:String
    var date:Date
    var recentMessage:String
    var seen:Bool
    
    init(key:String, sender: String, recipient:String, date:Date, recentMessage:String, seen:Bool) {
        self.key = key
        self.sender = sender
        self.recipient = recipient
        self.date = date
        self.recentMessage = recentMessage
        self.seen = seen
    }
    
    // Returns the UID of the conversations partner
    // i.e NOT the UID of the current user
    var partner_uid:String {
        guard let uid = Auth.auth().currentUser?.uid else { return "" }
        if sender != uid {
            return sender
        }
        return recipient
    }
    
    func printAll() {
        print("key: \(key)")
        print("sender: \(sender)")

        print("recentMessage: \(recentMessage)")
    }
}

class ChatsTableViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView:UITableView!
    
    var conversations = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView = UITableView(frame: view.bounds)
        let nib = UINib(nibName: "ChatTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "chatCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.separatorColor = UIColor.white
        tableView.separatorStyle = .singleLine
        title = "CHAT"
        view.addSubview(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeConversations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let user = Auth.auth().currentUser else { return }
        let ref = Database.database().reference().child("conversations/users/\(user.uid)")
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        cell.setConversation(conversations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChatTableViewCell
        if let partner = cell.partner, let image = cell.profileImageView.image {
            let controller = ChatViewController()
            controller.hidesBottomBarWhenPushed = true
            controller.conversation = conversations[indexPath.row]
            controller.partnerImage = image
            controller.partner = partner
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func observeConversations() {
        guard let user = Auth.auth().currentUser else { return }
        let ref = Database.database().reference().child("conversations/users/\(user.uid)")
        ref.observe(.value, with: { snapshot in

            var _conversations = [Conversation]()
            for child in snapshot.children {

                if let childSnap = child as? DataSnapshot,
                    let dict = childSnap.value as? [String:Any],
                    let key = dict["key"] as? String,
                    let sender = dict["sender"] as? String,
                    let recipient = dict["recipient"] as? String,
                    let text = dict["text"] as? String,
                    let timestamp = dict["timestamp"] as? Double,
                    let muted = dict["muted"] as? Bool, !muted,
                    let seen = dict["seen"] as? Bool {
                    
                    let date = Date(timeIntervalSince1970: timestamp/1000)
                    let conversation = Conversation(key: key, sender: sender, recipient: recipient, date: date, recentMessage: text, seen: seen)
                    _conversations.append(conversation)
                }
            }
            self.conversations = _conversations
            self.tableView.reloadData()

        })
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! ChatTableViewCell
            let name = cell.usernameLabel.text!
            
            let actionSheet = UIAlertController(title: "Block conversation with \(name)?", message: "Further messages from \(name) will be muted.", preferredStyle: .alert)
            
            let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
            
            actionSheet.addAction(cancelActionButton)
            
            let deleteActionButton: UIAlertAction = UIAlertAction(title: "Block", style: .destructive)
            { action -> Void in
                self.muteConversation(self.conversations[indexPath.row])
            }
            actionSheet.addAction(deleteActionButton)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func muteConversation(_ conversation:Conversation) {
        guard let user = Auth.auth().currentUser else { return }
        let ref = Database.database().reference()
        
        let obj = [
            "social/blocked/\(user.uid)/\(conversation.partner_uid)" : true,
            "social/blockedBy/\(conversation.partner_uid)/\(user.uid)" : true,
            "conversations/users/\(user.uid)/\(conversation.partner_uid)/muted": true
        ] as [String:Any]
        print("OBBJ: \(obj)")
        ref.updateChildValues(obj, withCompletionBlock: { error, ref in
            if error != nil {
                let alert = UIAlertController(title: "Error deleting conversation!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            } else {
                let alert = UIAlertController(title: "Conversation blocked!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            }
        })
    }
}




extension Date
{
    func timeStringSinceNow() -> String
    {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: self, to: Date())
        
        if components.day! >= 365 {
            return "\(components.day! / 365)y"
        }
        
        if components.day! >= 7 {
            return "\(components.day! / 7)w"
        }
        
        if components.day! > 0 {
            return "\(components.day!)d"
        }
        else if components.hour! > 0 {
            return "\(components.hour!)h"
        }
        else if components.minute! > 0 {
            return "\(components.minute!)m"
        }
        return "Now"
        //return "\(components.second)s"
    }
    
    func timeStringSinceNowWithAgo() -> String
    {
        let timeStr = timeStringSinceNow()
        if timeStr == "Now" {
            return timeStr
        }
        
        return "\(timeStr) ago"
    }
    
}

//
//  NewTabBarViewController.swift
//  jabMix1
//
//  Created by HG on 12/20/17.
//  Copyright © 2017 GGTECH. All rights reserved.
//

import UIKit
import Firebase

class NewTabBarViewController: UITabBarController {

    
    var numPendingRequests = 0
    var numUnseenConversations = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeNumPendingRequests()
        observeNumUnseenConversations()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sendFCMToken()
        observeNumPendingRequests()
        observeNumUnseenConversations()
        AuthService().getCurrentUserInfo()
        // Show notification center if the app launched from a notification
        // Typically from the background or killed app state
        if NotificationService.launchedFromNotification {
            showNotificationCenter()
            NotificationService.launchedFromNotification = false
        }
        
        // Observe if the app is opened from a notification
        // Typically from the foreground state
        NotificationCenter.default.addObserver(self, selector: #selector(showNotificationCenter), name: NotificationService.didLaunchFromNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observeNumUnseenConversations()
        // Stop observing if the app is opened from a notification
        NotificationCenter.default.removeObserver(self, name: NotificationService.didLaunchFromNotification, object: nil)
    }
    
    // Select the tab item with the notification center
    @objc func showNotificationCenter() {
        self.selectedIndex = 2
    }
    
    /**
     Sends the users private Firebase Cloud Messaging Token to the database
     to be used by the Cloud Functions for sending Push Notifications
     
     */
    func sendFCMToken() {
        guard let token = Messaging.messaging().fcmToken, let user = Auth.auth().currentUser else { return }
        let db = Database.database().reference()
        let ref = db.child("FCMToken/\(user.uid)")
        ref.setValue(token)
    }
    
    /**
     Observes the number of received requests that are PENDING
     and updates the App Badge Icon Number and tabBar Item accordingly
     
     */
    func observeNumPendingRequests() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Database.database().reference()
        let ref = db.child("receivedRequests/\(user.uid)").queryOrderedByValue().queryEqual(toValue: "PENDING")
        ref.observe(.value, with: { snapshot in
            self.numPendingRequests = Int(snapshot.childrenCount)
            self.setApplicationBadgeCount()
        })
    }
    
    func observeNumUnseenConversations() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Database.database().reference()
        let ref = db.child("conversations/users/\(user.uid)").queryOrdered(byChild: "seen").queryEqual(toValue: false)
        ref.observe(.value, with: { snapshot in
            self.numUnseenConversations = Int(snapshot.childrenCount)
            
            
          //  DispatchQueue.main.async{ self.setApplicationBadgeCount() }
            
            self.setApplicationBadgeCount()
        })
    }
    
    func setApplicationBadgeCount() {
        let total = numUnseenConversations + numPendingRequests
        UIApplication.shared.applicationIconBadgeNumber = Int(total)
        self.tabBar.items?[1].badgeValue = numPendingRequests > 0 ? "\(numPendingRequests)" : nil
        
        self.tabBar.items?[2].badgeValue = numUnseenConversations > 0 ? "\(numUnseenConversations)" : nil
    }
    
    
}

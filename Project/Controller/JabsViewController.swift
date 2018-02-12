//
//  JabsViewController.swift
//  jabMix1
//
//  Created by HG on 1/11/18.
//  Copyright © 2018 GGTECH. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class JabsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellIdentifier = "jabCell"
    var tableView:UITableView!
    var requests = [Request]()
    
    var receivedRequestsKeys:[String]?
    var sentRequestKeys:[String]?
    
    @IBAction func logOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            // there is a user signed in
            do {
                try? Auth.auth().signOut()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
       
        
        
//        self.edgesForExtendedLayout = UIRectEdge()
//        self.extendedLayoutIncludesOpaqueBars = false
//        self.automaticallyAdjustsScrollViewInsets = false

//
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        let nib = UINib(nibName: "JabTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.white
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        view.addSubview(tableView)
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getReceivedRequests { requestKeys in
            self.receivedRequestsKeys = requestKeys
            self.getAllRequests()
        }
        
        getSentRequests { requestKeys in
            self.sentRequestKeys = requestKeys
            self.getAllRequests()
        }
        

    }
    
    func getAllRequests() {
        guard let sentRequests = self.sentRequestKeys else { return }
        guard let receivedRequests = self.receivedRequestsKeys else { return }
        
        var mergedKeys = sentRequests
        mergedKeys.append(contentsOf: receivedRequests)
        
        getRequestsLists(mergedKeys) { _requests in
            self.requests = _requests.sorted(by: { $0.timestamp > $1.timestamp })
            self.tableView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Get the list of incoming RECEIVED requests
     */
    func getReceivedRequests(completion: @escaping((_ requestKeys:[String])->())) {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Database.database().reference()
        let ref = db.child("receivedRequests/\(user.uid)")
        
        ref.observe(.value, with: { snapshot in
            var requestKeys = [String]()
            for request in snapshot.children {
                if let reqSnap = request as? DataSnapshot {
                    requestKeys.append(reqSnap.key)
                }
            }
            
            print("receieved keys: \(requestKeys)")
            
            completion(requestKeys)
        })
    }
    
    func getSentRequests(completion: @escaping((_ requestKeys:[String])->())) {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Database.database().reference()
        let ref = db.child("sentRequests/\(user.uid)")
        
        ref.observe(.value, with: { snapshot in
            var requestKeys = [String]()
            for request in snapshot.children {
                if let reqSnap = request as? DataSnapshot {
                    requestKeys.append(reqSnap.key)
                }
            }
            
            print("sent keys: \(requestKeys)")
            completion(requestKeys)
        })
    }
    
    func getRequestsLists(_ keys:[String], completion: @escaping((_ requests:[Request])->())) {
        if keys.count == 0 {
            return completion([])
        }
        
        let db = Database.database().reference()
        var _requests = [Request]()
        var count = 0
        for key in keys{
            let ref = db.child("requests/\(key)")
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if var reqDict = snapshot.value as? [String:Any] {
                    reqDict["key"] = snapshot.key
                    _requests.append(Request(dict: reqDict))
                }
                
                count += 1
                if count >= keys.count {
                    return completion(_requests)
                }
            })
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! JabTableViewCell
        let request = requests[indexPath.row]
        cell.setRequest(request)
//        let typeStr = request.isSenderCurrentUser ? "Sent:" : "Received:"
//        cell.textLabel?.text = "\(typeStr) \(request.name) (\(request.status))"
//        cell.detailTextLabel?.text = typeStr
        return cell
    }
    
    /**
     Display options when a cell is selected
     
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        showRequestDetailView(requests[indexPath.row])
    }
    
    func showRequestDetailView(_ request:Request) {
        let requestVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestDetailViewController") as! RequestDetailViewController
        requestVC.request = request
        self.navigationController?.pushViewController(requestVC, animated: true)
    }

}

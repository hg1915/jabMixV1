//
//  FindAPartnerViewController.swift
//  jabMix1
//
//  Created by HG on 10/19/17.
//  Copyright © 2017 GGTECH. All rights reserved.
//
//
//import UIKit
//import FirebaseDatabase
//import Firebase
//import FirebaseStorage
//import FirebaseAuth
//
//
//class FindAPartnerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//
//
//    var usersArray = [Users]()
//    var dataBaseRef: DatabaseReference! {
//        return Database.database().reference()
//    }
//
//
//    @IBOutlet weak var partnerTableView: UITableView!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        fetchUsers()
//        partnerTableView.delegate = self
//        partnerTableView.dataSource = self
//        partnerTableView.register(UINib(nibName: "FindAPartnerCellTableViewCell", bundle: nil), forCellReuseIdentifier: "partnerCell")
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//      fetchUsers()
//    }
//
//    func fetchUsers(){
//
//        dataBaseRef.child("users").observe(.value, with: { (snapshot) in
//            var results = [Users]()
//
//            for user in snapshot.children {
//
//                let user = Users(snapshot: user as! DataSnapshot)
//
//                if user.uid != Auth.auth().currentUser!.uid {
//                    results.append(user)
//                }
//
//            }
//
//            self.usersArray = results.sorted(by: { (u1, u2) -> Bool in
//                u1.username < u2.username
//            })
//            self.partnerTableView.reloadData()
//
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//
//    }
//
//
//
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "partnerCell", for: indexPath) as! FindAPartnerCellTableViewCell
//       cell.configureCell(user: usersArray[indexPath.row])
//
//     //   cell.configureCell(user: usersArray[indexPath.row])
//
//
//        return cell
//    }
//
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return usersArray.count
//
//    }
//
//}



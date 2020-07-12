//
//  ConversationsViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase

class ConversationsViewController: UIViewController {

    // 1: Connect table view
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var userSelection: String?
    var users: [String] = []
    // 2: Read user from sender variable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsers()
        
        // The table view is going to look at its self when loading data
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func getUsers() {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in

            self.users = []

            if let e = error {
                print("There was an issue retieving data from Firestore: \(e)")
            } else {
                if let snapshotDocs = querySnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        if let name = data["firstName"] as? String {
                            self.users.append(name)

                            // Reload view
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.conversationsSegue {
            let destinationVC = segue.destination as! ChatViewController
            destinationVC.titleName = userSelection
        }
    }
    
    
}

// 3: Make some data with DataSource
extension ConversationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: make sure users are not nil
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        // TODO: make sure users are not nil
        cell.textLabel?.text = users[indexPath.row]
        return cell
    }
    
    
}
// Delegate is responsible for user interaction
extension ConversationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 5: Direct to chat view
        // TODO: make sure users are not nil
        userSelection = users[indexPath.row]
        self.performSegue(withIdentifier: K.conversationsSegue, sender: self)
    }
}


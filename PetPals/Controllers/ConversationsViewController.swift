//
//  ConversationsViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController {

    // 1: Connect table view
    @IBOutlet weak var tableView: UITableView!
    
    var userSelection: String?
    
    // 2: Read user from sender variable
    var users: [Message] = [
        Message.init(sender: "v@g.com", body: "Hey!"),
        Message.init(sender: "nikkiv@g.com", body: "Hello"),
        Message.init(sender: "rosalie@g.com", body: "Whats up?")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The table view is going to look at its self when loading data
        tableView.dataSource = self
        tableView.delegate = self
        
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
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = users[indexPath.row].sender
        return cell
    }
    
    
}
// Delegate is responsible for user interaction
extension ConversationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 5: Direct to chat view
        userSelection = users[indexPath.row].sender
        self.performSegue(withIdentifier: K.conversationsSegue, sender: self)
    }
}


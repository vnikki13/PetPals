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

    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    // Label for when there are no conversations
    // Want to show this label instead of the tableView
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    let db = Firestore.firestore()
    var otherUserName: String?
    var otherUserEmail: String?
    var userNames: [String] = []
    var userEmails: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
//        getUsers()
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Calling validateAuth function when loading view
        validateAuth()
    }
    
    // Validating whether a person is logged in or not using firebase
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    // Function for setting up the table view
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func didTapComposeButton() {
        // Want to show newConversation controller
//        let vc = NewConversationViewController()
//        vc.completion = { [weak self] result in
//            print("\(result)")
//            self?.createNewConversation(result: result)
//        }
//        let navVC = UINavigationController(rootViewController: vc)
//        present(navVC, animated: true)
        print("pushed compose button")
        
    }
    
    private func fetchConversations() {
        guard let email = Auth.auth().currentUser?.email else {
            print("Couldn't find email")
            return
        }
        print("called get conversations")
        DatabaseManager().getAllConversations(for: email, completion: { result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("conversation is empty")
                    return
                }
                
                self.tableView.isHidden = false
                self.conversations = conversations
                print(conversations)
                
                DispatchQueue.main.async {
                    print("reloading table view")
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get convos: \(error)")
            }
        })
    }
    
    
    func getUsers() {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in

            self.userNames = []

            if let e = error {
                print("There was an issue retieving data from Firestore: \(e)")
            } else {
                if let snapshotDocs = querySnapshot?.documents {
                    for doc in snapshotDocs {
                        let data = doc.data()
                        if let name = data["firstName"] as? String, let email = data["email"] as? String {
                            self.userNames.append(name)
                            self.userEmails.append(email)
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
        let destinationVC = segue.destination as! ChatViewController
        destinationVC.title = otherUserName
        destinationVC.otherUserEmail = otherUserEmail
        
    }
    
}

// 3: Make some data with DataSource
extension ConversationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: make sure users are not nil
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        // TODO: make sure users are not nil
        //        cell.textLabel?.text = userNames[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    
}
// Delegate is responsible for user interaction
extension ConversationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
 
//        otherUserName = userNames[indexPath.row]
//        otherUserEmail = userEmails[indexPath.row]
//        self.performSegue(withIdentifier: K.conversationsSegue, sender: self)
    }

}


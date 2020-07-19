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

    private let db = Firestore.firestore()
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
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        noConversationsLabel.frame = CGRect(x: view.width/4,
                                            y: (view.height-200)/2,
                                            width: view.width/2,
                                            height: 200)
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
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = result.email

        let vc = ChatViewController(email: email, id: nil, name: name)
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func fetchConversations() {
        guard let email = Auth.auth().currentUser?.email else {
            print("Couldn't find email to get conversations")
            return
        }
        
        DatabaseManager().getAllConversations(for: email, completion: { result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    // show no conversation label
                    print("conversation is empty")
                    self.updateUI()
                    return
                }
                
                self.tableView.isHidden = false
                self.conversations = conversations
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateUI()
                }
                
            case .failure(let error):
                print("failed to get convos: \(error)")
            }
        })
    }
}


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
        cell.configure(with: model)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func updateUI() {
        if conversations.isEmpty {
            self.noConversationsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noConversationsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
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
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(email: model.otherUserEmail, id: model.id, name: model.name)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }

}


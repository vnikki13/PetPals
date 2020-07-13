//
//  ChatViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    let db = Firestore.firestore()
    var otherUserEmail: String?
    
    var isNewConversation = false
    var messages: [MessageType] = []
    
    public struct Sender: SenderType {
        public let senderId: String
        public let displayName: String
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        // The table view is going to look at its self when loading data
//        tableView.dataSource = self
        
//        loadMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let senderEmail = Auth.auth().currentUser?.email, let recipentEmail = otherUserEmail else {
                return
        }
        
        print("Sending message: \(text)")
        
        
//        DatabaseManager()
//        db.collection("conversations")
//            .whereField("participants", in: [[senderEmail, recipentEmail], [recipentEmail, senderEmail]])
//            .getDocuments() { (querySnapshot, err) in
//                
//                if querySnapshot!.isEmpty {
//                    // Start a new conversation
//                    print("no known conversations, starting a new one")
//                    DatabaseManager().insertNewConversation(with: senderEmail, and: recipentEmail)
//                } else {
//                    // Continue on with conversation
//                    for doc in querySnapshot!.documents {
//                        print("conversation with id: \(doc.documentID) exists")
//                        self.db.collection("conversations/\(doc.documentID)/messages").document().setData([
//                            "body": text,
//                            "sender": senderEmail
//                        ])
//                    }
//                }
//        }
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        return Sender(senderId: "\(Date())", displayName: title!)
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
    
//    func loadMessages() {
//
//        db.collection(K.FStore.collectionName)
//            .order(by: K.FStore.dateField)
//            .addSnapshotListener { (querySnapshot, error) in
//
//            self.messages = []
//
//            if let e = error {
//                print("There was an issue retieving data from Firestore: \(e)")
//            } else {
//                if let snapshotDocs = querySnapshot?.documents {
//                    for doc in snapshotDocs {
//                        let data = doc.data()
//                        if let sender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
//                            let newMessage = Message.init(sender: sender, body: messageBody)
//                            self.messages.append(newMessage)
//
//                            // Good practice to use this method to reload a view
//                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
//                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
//                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//}

// DataSource is responsible for populating the table with data
//extension ChatViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let message = messages[indexPath.row]
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
//        cell.textLabel?.text = messages[indexPath.row].body
//
//        // Current user logged in
//        if message.sender == Auth.auth().currentUser?.email {
//            cell.backgroundColor = .red
//        } else {
//            cell.backgroundColor = .green
//        }
//
//
//        return cell
//    }
//}

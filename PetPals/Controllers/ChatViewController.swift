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
    
    public let recipientEmail: String
    public let recipientName: String
    private var conversationId: String?
    public var isNewConversation = false
    
    var messages = [Message]()
    
    public var currentUser: Sender? {
        guard let email = Auth.auth().currentUser?.email else {
            return nil
        }
        
        return Sender(senderId: email, displayName: "Me")
    }
    
    
    
    init(email: String, id: String?, name: String) {
        self.conversationId = id
        self.recipientEmail = email
        self.recipientName = name
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if let conversationID = conversationId {
            print("listening for messages")
            listenForMessages(id: conversationID, shouldScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        print("current messages: \(messages)")
        DatabaseManager().getAllMessagesForConversation(with: id, completion: { result in
            print("listening for messages with id: \(id)")
            
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self.messages = messages
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
                
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith message: String) {
        guard !message.replacingOccurrences(of: " ", with: "").isEmpty,
            let senderEmail = Auth.auth().currentUser?.email else {
                return
        }
        
        print("Sending message: \(message)")
        DatabaseManager().sendMessage(from: senderEmail, to: recipientEmail, aka: recipientName, with: message)
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = currentUser {
            return sender
        }
         
        fatalError("Current user email is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}



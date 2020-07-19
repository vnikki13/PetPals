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
    
    private var senderPhotoURL: URL?
    private var recipientPhotoURL: URL?
    
    public let recipientEmail: String
    public let recipientName: String
    private var conversationId: String?
    
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
        
        if conversationId == nil {
            guard let userEmail = Auth.auth().currentUser?.email else {
                return
            }
            
            DatabaseManager().conversationExists(for: userEmail, with: recipientEmail, completion: { success in
                guard let success = success else {
                    return
                }
                
                self.conversationId = success
            })
        }
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationID = conversationId {
            listenForMessages(id: conversationID)
        }
    }
    
    private func listenForMessages(id: String) {
        DatabaseManager().getAllMessagesForConversation(with: id, completion: { result in
            
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self.messages = messages
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == currentUser?.senderId {
            // show current user image
            if let currentUserImageURL = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            } else {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                
                // fetch url
                let path = "images/\(email)/photo_1.png"
                StorageManager.shared.downloadURL(for: path, completion: { result in
                    switch result {
                    case .success(let url):
                        self.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print(error)
                    }
                })
            }
        } else {
            // show recipient image
            let email = recipientEmail
            
            // fetch url
            let path = "images/\(email)/photo_1.png"
            StorageManager.shared.downloadURL(for: path, completion: { result in
                switch result {
                case .success(let url):
                    self.recipientPhotoURL = url
                    DispatchQueue.main.async {
                        avatarView.sd_setImage(with: url, completed: nil)
                    }
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith message: String) {
        guard !message.replacingOccurrences(of: " ", with: "").isEmpty,
            let senderEmail = Auth.auth().currentUser?.email else {
                return
        }
        
        print("Sending message: \(message)")
        messageInputBar.inputTextView.text = nil
        DatabaseManager().sendMessage(from: senderEmail, to: recipientEmail, aka: recipientName, with: message)
        
        // Reload page after message is sent
        DatabaseManager().conversationExists(for: senderEmail, with: recipientEmail, completion: { id in
            guard let conversationId = id else {
                return
            }
            
            self.listenForMessages(id: conversationId)
        })
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> SenderType {
        if let sender = currentUser {
            return sender
        }
         
        // TODO: Stop listening for messages?
        
        fatalError("Current user email is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}



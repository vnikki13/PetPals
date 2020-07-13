//
//  DatabaseManager.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/11/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import Foundation
import Firebase

class DatabaseManager {
    
    let db = Firestore.firestore()
    var recipientFirstName = String()
    
    // Authenticating a new user
    func authenticateNewUser(_ user: User, with password: String, completion: @escaping ((Bool) -> Void)) {
        
        Auth.auth().createUser(withEmail: user.email, password: password) { authResult, error in
            if let err = error?.localizedDescription {
                print(err)
                completion(false)
            } else {
                print("Successfully authenticated \(user.email)")
                completion(true)
            }
        }
    }
    
    // Adding a new user to the User collection
    func insertNewUser(_ user: User) {
        db.collection("users").document(user.email).setData([
            "firstName": user.firstName,
            "lastName": user.lastName,
            "email": user.email
        ], merge: false, completion: { err in
            if let err = err?.localizedDescription {
                print("Error adding Document: \(err)")
            } else {
                print("\(user.email) added to users collection")
            }
        })
    }
    
    
    // Get recipient name
    func getRecipientName(with email: String) {
        let docRef = db.collection("users").document(email)
        
        docRef.getDocument{ (document, error ) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.recipientFirstName = dataDescription!["firstName"] as! String
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // Adding a message to the messages collection for a specific ID
    func insertMessage(with docID: String, for sender: String, with text: String) {
        self.db.collection("conversations/\(docID)/messages").document().setData([
            "message": text,
            "sender": sender,
            "date": Date()
        ])
    }
    
    // Starting a new conversation
    func insertNewConversation(with senderEmail: String, and recipentEmail: String, message: String) {
        getRecipientName(with: recipentEmail)
        let docID = "\(senderEmail)_\(recipentEmail)"
        db.collection("conversations").document(docID).setData([
        "participants": [senderEmail, recipentEmail],
        "sendDate": Date(),
        "message": message,
        "recipientEmail": recipentEmail,
        "recipientName": recipientFirstName,
        "isRead": false
        
        ]) { (error) in
            if let e = error {
                print("There was an issue saving to the database: \(e)")
            } else {
                print("Created new convo and saved message to database")
            }
        }
        insertMessage(with: docID, for: senderEmail, with: message)
    }
    
    // Sending a message
    func sendMessage(from senderEmail: String, to recipentEmail: String, with message: String) {
        getRecipientName(with: "vn@g.com")
        db.collection("conversations")
            .whereField("participants", in: [[senderEmail, recipentEmail], [recipentEmail, senderEmail]])
            .getDocuments() { (querySnapshot, err) in
                
                if querySnapshot!.isEmpty {
                    // Start a new conversation
                    print("no known conversations, starting a new one")
                    self.insertNewConversation(with: senderEmail, and: recipentEmail, message: message)
                } else {
                    // Continue on with conversation
                    for doc in querySnapshot!.documents {
                        print("conversation with id: \(doc.documentID)")
                        // update fields to represent latest message sent
//                      // TODO: call insertNewMessage for this task
                        self.db.collection("conversations").document(doc.documentID).setData([
                            "participants": [senderEmail, recipentEmail],
                            "sendDate": Date(),
                            "message": message,
                            "recipientEmail": recipentEmail,
                            "recipientName": self.recipientFirstName,
                            "isRead": false
                        ])
                        
                        self.insertMessage(with: "\(doc.documentID)", for: senderEmail, with: message)
                    }
                }
        }
    }
    
    // Retrieve all conversations for current user
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        db.collection("conversations").whereField("participants", arrayContains: email).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(.failure(error!))
                return
            }
            
            let conversations: [Conversation] = documents.compactMap({ doc in
                let conversationId = doc.documentID
                let timestamp: Timestamp = (doc.data() as AnyObject).value(forKey: "sendDate")! as! Timestamp
                let requestedDate = timestamp.dateValue()
                
                guard let recipientEmail = doc.data()["recipientEmail"] as? String,
                    let message = doc.data()["message"] as? String,
                    let recipientName = doc.data()["recipientName"] as? String else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: requestedDate,
                                                        message: message,
                                                        isRead: false)
                
                return Conversation(id: conversationId,
                                    name: recipientName,
                                    otherUserEmail: recipientEmail,
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        }
    }
    
    // Retrieving all users from database for search results
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("problem getting a list of all users")
                completion(.failure(e))
            } else {
                if let snapshotDocs = querySnapshot?.documents {
                    let userInfo: [[String: String]] = snapshotDocs.map({ doc in
                        let firstName = doc.data()["firstName"] as! String
                        let email = doc.data()["email"] as! String
                        return ["name": firstName, "email": email]
                    })
                    completion(.success(userInfo))
                }
            }
        }
    }
}


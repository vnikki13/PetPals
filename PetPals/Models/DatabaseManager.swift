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
//                print("Document data: \(dataDescription!["firstName"])")
                self.recipientFirstName = dataDescription!["firstName"] as! String
            } else {
                print("Document does not exist")
            }
        }
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
        
        self.db.collection("conversations/\(docID)/messages").document().setData([
            "message": message,
            "sender": senderEmail,
            "date": Date()
        ])
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
                        self.db.collection("conversations").document(doc.documentID).setData([
                            "participants": [senderEmail, recipentEmail],
                            "sendDate": Date(),
                            "message": message,
                            "recipientEmail": recipentEmail,
                            "recipientName": self.recipientFirstName,
                            "isRead": false
                        ])
                        
                        
                        self.db.collection("conversations/\(doc.documentID)/messages").document().setData([
                            "message": message,
                            "sender": senderEmail,
                            "date": Date()
                        ])
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
                
                guard let recipientEmail = doc.data()["recipientEmail"],
                    let message = doc.data()["message"],
                    let recipientName = doc.data()["recipientName"] else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: requestedDate,
                                                        message: message as! String,
                                                        isRead: false)
                
                return Conversation(id: conversationId,
                                    name: recipientName as! String,
                                    otherUserEmail: recipientEmail as! String,
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        }
    }
    
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
    
    
//    public func getConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
//        db.collection("conversations").whereField("participants", arrayContains: [email]).addSnapshotListener { querySnapshot, error in
//            guard let value = querySnapshot?.documents else{
//                completion(.failure(error!))
//                return
//            }
//
//            let conversations: [Conversation] = value.compactMap({ dictionary in
//                guard let conversationId = dictionary["id"] as? String,
//                    let name = dictionary["name"] as? String,
//                    let otherUserEmail = dictionary["other_user_email"] as? String,
//                    let latestMessage = dictionary["latest_message"] as? [String: Any],
//                    let message = latestMessage["message"] as? String,
//                    let isRead = latestMessage["is_read"] as? Bool else {
//                        return nil
//                }
//
//                let latestMmessageObject = LatestMessage(date: Date(),
//                                                         message: message,
//                                                         isRead: isRead)
//                return Conversation(id: conversationId,
//                                    name: name,
//                                    otherUserEmail: otherUserEmail,
//                                    latestMessage: latestMmessageObject)
//            })
//
//            completion(.success(conversations))
//        }
//    }
}


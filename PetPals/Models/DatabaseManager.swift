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
    
    // Starting a new conversation
    func insertNewConversation(with senderEmail: String, and recipentEmail: String) {
        db.collection("conversations").document("\(senderEmail)_\(recipentEmail)").setData([
        "participants": [senderEmail, recipentEmail],
        "sendDate": Date()
        ]) { (error) in
            if let e = error {
                print("There was an issue saving to the database: \(e)")
            } else {
                print("Created new convo and saved message to database")
            }
        }
    }
    
    // Sending a message
    func sendMessage(from senderEmail: String, to recipentEmail: String, with text: String) {
        db.collection("conversations")
            .whereField("participants", in: [[senderEmail, recipentEmail], [recipentEmail, senderEmail]])
            .getDocuments() { (querySnapshot, err) in
                
                if querySnapshot!.isEmpty {
                    // Start a new conversation
                    print("no known conversations, starting a new one")
                    self.insertNewConversation(with: senderEmail, and: recipentEmail)
                } else {
                    // Continue on with conversation
                    for doc in querySnapshot!.documents {
                        print("conversation with id: \(doc.documentID) exists")
                        self.db.collection("conversations/\(doc.documentID)/messages").document().setData([
                            "body": text,
                            "sender": senderEmail
                        ])
                    }
                }
        }
    }
    
    // Retrieve all conversations
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        db.collection("conversations").whereField("participants", arrayContains: email).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(.failure(error!))
                return
            }
            
            let conversations: [Conversation] = documents.compactMap({ doc in

                let conversationId = doc.documentID
                let latestMessageObject = LatestMessage(date: Date(),
                                                        message: "Hi boy",
                                                        isRead: false)
                
                return Conversation(id: conversationId,
                                    name: "test",
                                    otherUserEmail: "othertest",
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
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

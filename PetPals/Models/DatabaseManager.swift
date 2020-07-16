//
//  DatabaseManager.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/11/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class DatabaseManager {
    
    let db = Firestore.firestore()
    
//    // Date formater
//    public let dateFormatter: DateFormatter = {
//        let formattre = DateFormatter()
//        formattre.dateStyle = .medium
//        formattre.timeStyle = .long
//        formattre.locale = .current
//        print("returning formated date")
//        return formattre
//    }()
    
    // Authenticating a new user
    func authenticateNewUser(_ user: User, with password: String, completion: @escaping ((Bool) -> Void)) {
        
        Auth.auth().createUser(withEmail: user.email, password: password) { authResult, error in
            if let err = error?.localizedDescription {
                print(err)
                completion(false)
            } else {
                print("Successfully authenticated \(user.email)")
                
                UserDefaults.standard.set(user.email, forKey: "email")
                UserDefaults.standard.set("\(user.firstName)", forKey: "firstName")
                completion(true)
            }
        }
    }
    
    func getDataFor(email: String, completion: @escaping (Result<Any, Error>) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments{ (querySnapshot, err) in
            if let err = err {
                print("Error getting docment: \(err)")
                completion(.failure(err))
            } else {
                for document in querySnapshot!.documents {
                    completion(.success(document.data()["firstName"]!))
                }
            }
        }
    }
    
    // Adding a new dog to current user collection
    func insertNewDog(with dog: Dog) {
        guard let currentUser = Auth.auth().currentUser?.email else {
            return
        }
        
        // inserting dog to current user profile
        db.collection("users/\(currentUser)/dogs").document().setData([
            "name": dog.name,
            "age": dog.age,
            "bio": dog.aboutMe,
            "photos": dog.photos
        ], merge: false, completion: { err in
            if let err = err?.localizedDescription {
                print("Error adding Document: \(err)")
            } else {
                print("\(dog.name) added to \(currentUser) dog collection")
            }
        })
        
        // inserting dog to list of all dogs
        db.collection("dogs").document("\(currentUser)_\(dog.name)").setData([
            "name": dog.name,
            "age": dog.age,
            "bio": dog.aboutMe,
            "photos": dog.photos
        ])
        print("done inserting new dog")
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
    
    // Sending a message
    func sendMessage(from senderEmail: String,
                     to recipientEmail: String,
                     aka recipientName: String,
                     with message: String) {
        
        // Saving messages to users email conversations collection
        let senderID = "\(senderEmail)_\(recipientEmail)"
        
        self.db.collection("users/\(senderEmail)/conversations/\(senderID)/messages").addDocument(data: [
            "message": message,
            "dateSent": Date(),
            "sender": senderEmail
        ])
        
        // update latest message for user
        db.collection("users/\(senderEmail)/conversations").document(senderID).setData([
            "isRead": false,
            "recipientEmail": recipientEmail,
            "recipientName": recipientName,
            "message": message,
            "dateSent": Date()
        ]) { err in
            if let err = err {
                print("Error writing to document: \(err)")
            } else {
                print("Document written to users/\(senderEmail)/conversations!")
            }
        }
        
        
        // Saving messages to recipients conversations collection
        let recipientID = "\(recipientEmail)_\(senderEmail)"
        
        guard let userName = UserDefaults.standard.value(forKey: "firstName") else {
            print("can't find user name")
            return
        }
        
        self.db.collection("users/\(recipientEmail)/conversations/\(recipientID)/messages").addDocument(data: [
            "message": message,
            "dateSent": Date(),
            "sender": senderEmail
        ])
        
        // update latest message for recipient
        db.collection("users/\(recipientEmail)/conversations").document(recipientID).setData([
            "isRead": false,
            "recipientEmail": senderEmail,
            "recipientName": userName,
            "message": message,
            "dateSent": Date()
        ]) { err in
            if let err = err {
                print("Error writing to document: \(err)")
            } else {
                print("Document written to users/\(recipientEmail)/conversations!")
            }
        }
    }
    
    // Retrieve all conversations for current user
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        db.collection("users/\(email)/conversations/").addSnapshotListener { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(err!)")
                completion(.failure(err!))
                return
            }
            
            let conversations: [Conversation] = documents.compactMap({ doc in
                let conversationID = doc.documentID
                let timestamp: Timestamp = (doc.data() as AnyObject).value(forKey: "dateSent")! as! Timestamp
                let requestedDate = timestamp.dateValue()
                
                guard let recipientEmail = doc.data()["recipientEmail"] as? String,
                    let message = doc.data()["message"] as? String,
                    let recipientName = doc.data()["recipientName"] as? String else {
                        return nil
                }
                let latestMessageObject = LatestMessage(date: requestedDate,
                                                        message: message,
                                                        isRead: false)
                
                return Conversation(id: conversationID,
                                    name: recipientName,
                                    otherUserEmail: recipientEmail,
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        }
    }
    
    // Retrieving all dogs from database for search
    public func getAllDogs(completion: @escaping (Result<[Dog], Error>) -> Void) {
        db.collection("dogs").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("problem getting a list of all dogs")
                completion(.failure(e))
            } else {
                if let snapshotDocs = querySnapshot?.documents {
                    let dogInfo: [Dog] = snapshotDocs.map({ doc in
                        let name = doc.data()["name"] as! String
                        let age = doc.data()["age"] as! String
                        let bio = doc.data()["bio"] as! String
                        let photos = doc.data()["photos"] as! [Any]
//
//                        // TODO: download images from reference
                        return Dog(name: name,
                                   aboutMe: bio,
                                   age: age,
                                   photos: photos)
                    })
                    
                    completion(.success(dogInfo))
                }
            }
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
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            print("current user email dosn't exist")
            return
        }

        db.collection("users/\(currentUserEmail)/conversations/\(id)/messages").order(by: "dateSent")
            .addSnapshotListener { querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    completion(.failure(error!))
                    return
                }
                
                guard let senderName: String = UserDefaults.standard.value(forKey: "firstName") as? String else {
                    print("can't find user name")
                    return
                }
                
                let messages: [Message] = documents.compactMap({ doc in
                    guard let senderEmail = doc.data()["sender"] as? String,
                    let message = doc.data()["message"] as? String else {
                        print("returning nil")
                        return nil
                }
                
                let sender = Sender(senderId: senderEmail,
                                    displayName: senderName)
                
                return Message(sender: sender,
                        messageId: doc.documentID,
                        sentDate: Date(),
                        kind: .text(message))
            })
            completion(.success(messages))
        }
    }
}


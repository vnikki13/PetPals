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
}

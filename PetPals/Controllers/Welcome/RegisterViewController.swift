//
//  RegisterViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func addDogInfoPressed(_ sender: UIButton) {
        
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            // TODO: create check for email and password fields and alert user of error
            print("invalid register info")
            return
        }
        
        let newUser = User(firstName: firstName, lastName: lastName, email: email)
        
        // TODO: Uncomment after register process is setup
//        self.performSegue(withIdentifier: "RegisterToDogInfo", sender: self)
        
        
        DatabaseManager().authenticateNewUser(newUser, with: password, completion: { success in
            if success {

                DatabaseManager().insertNewUser(newUser)

                self.performSegue(withIdentifier: "RegisterToDogInfo", sender: self)

            } else {
                // TODO: create check for email and password fields and alert user of error
                print("Unable to create account")
            }
        })
        
    }
}

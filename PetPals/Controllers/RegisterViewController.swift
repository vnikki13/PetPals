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

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    // TODO: create a label or popup for the user
                    print(error.localizedDescription)
                } else {
                    print("success")
                    self.performSegue(withIdentifier: "RegisterToHome", sender: self)
                }
            }
        }
    }
}

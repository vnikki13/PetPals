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
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 20
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }
        
        if firstName.isEmpty ||
            lastName.isEmpty ||
            email.isEmpty ||
            password.isEmpty {
            alertUserRegisterError()
            
        } else {
            let newUser = User(firstName: firstName, lastName: lastName, email: email)
            DatabaseManager().authenticateNewUser(newUser, with: password, completion: { result in
                switch result {
                case .success(let message):
                    print(message)
                    self.performSegue(withIdentifier: "RegisterToDogInfo", sender: self)
                case .failure(let error):
                    self.alertUserRegisterError(message: error.localizedDescription)
                }
            })
            
            DatabaseManager().insertNewUser(newUser)
        }
    }
    
    func alertUserRegisterError(message: String = "Please enter all information to create a new account.") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

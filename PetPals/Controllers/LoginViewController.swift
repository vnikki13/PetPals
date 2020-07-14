//
//  LoginViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    // TODO: create a label or popup for the user
                    print(error.localizedDescription)
                } else {
                    DatabaseManager().getDataFor(email: email, completion: {result in
                        switch result {
                        case .success(let data):
                            guard let firstName = data as? String else {
                                print(data)
                                return
                            }
                            
                            UserDefaults.standard.set(firstName, forKey: "firstName")
                            print("loged in as \(firstName), with email: \(email)")
                            
                        case .failure(let error):
                            print("Failed to read data with error \(error)")
                        }
                    })
                    
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
    }
    
}

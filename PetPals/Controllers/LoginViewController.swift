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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    // Alert label for the user
                    self.alertUserLoginError(with: error.localizedDescription)
                } else {
                    DatabaseManager().getDataFor(email: email, completion: {result in
                        switch result {
                        case .success(let data):
                            guard let firstName = data as? String else {
                                return
                            }
                            
                            UserDefaults.standard.set(email, forKey: "email")
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
    
    func alertUserLoginError(with message: String) {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
}

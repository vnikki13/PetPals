//
//  ViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        validateAuth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerButton.layer.cornerRadius = 20
        self.loginButton.layer.cornerRadius = 20
    }
    
    private func validateAuth() {
        if Auth.auth().currentUser != nil {
            navigationController?.isNavigationBarHidden = true
            performSegue(withIdentifier: "WelcomeToTabBar", sender: self)
        }
    }

    @IBAction func unwindToWelcome(_ unwindSegue: UIStoryboardSegue) {
    }

}


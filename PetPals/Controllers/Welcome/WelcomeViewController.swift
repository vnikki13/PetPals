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
    
    private var shouldHideNavigationBar: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        shouldHideNavigationBar = false
        navigationController?.isNavigationBarHidden = true
        validateAuth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerButton.layer.cornerRadius = 20
        self.loginButton.layer.cornerRadius = 20
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = shouldHideNavigationBar
    }
    
    private func validateAuth() {
        if Auth.auth().currentUser != nil {
            shouldHideNavigationBar = true
            performSegue(withIdentifier: "WelcomeToTabBar", sender: self)
        }
    }

    @IBAction func unwindToWelcome(_ unwindSegue: UIStoryboardSegue) {
    }

}


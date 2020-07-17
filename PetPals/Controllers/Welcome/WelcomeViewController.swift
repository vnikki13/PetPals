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
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        super.viewWillAppear(false)
        validateAuth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func validateAuth() {
        print("validating user")
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "WelcomeToTabBar", sender: self)
        }
    }

    @IBAction func unwindToWelcome(_ unwindSegue: UIStoryboardSegue) {
    }

}


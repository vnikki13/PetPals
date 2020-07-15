//
//  HomeViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
    }
    
    private func validateAuth() {
        if Auth.auth().currentUser == nil {
            print("trying to perform seque")
            performSegue(withIdentifier: "HomeToLogin", sender: self)
            tabBarController?.hidesBottomBarWhenPushed = true
        }
    }
    
}

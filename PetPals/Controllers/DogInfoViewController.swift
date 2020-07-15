//
//  DogInfoViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/14/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class DogInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func AddDogInfoPressed(_ sender: UIButton) {
        // TODO: validate dog info before moving onto the next screen
        performSegue(withIdentifier: "DogInfoToDogBio", sender: self)
    }
}

//
//  DogInfoViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/14/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class DogInfoViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageNumLabel: UILabel!
    @IBOutlet weak var ageSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func ageSliderChanged(_ sender: UISlider) {
        ageNumLabel.text = "\(Int(sender.value)) years"
    }
    
    
    @IBAction func AddDogInfoPressed(_ sender: UIButton) {
        // TODO: validate dog info before moving onto the next screen
        performSegue(withIdentifier: "DogInfoToDogBio", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DogInfoToDogBio" {
            let vc = segue.destination as! DogBioViewController
            vc.age = ageNumLabel.text
            vc.dogName = nameTextField.text
        }
    }
    
}

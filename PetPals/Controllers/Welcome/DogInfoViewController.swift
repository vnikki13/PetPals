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
    @IBOutlet weak var genderSelector: UISegmentedControl!
    @IBOutlet weak var fixedSwitch: UISwitch!
    @IBOutlet weak var addDogInfoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDogInfoButton.layer.cornerRadius = 20
    }
    
    @IBAction func ageSliderChanged(_ sender: UISlider) {
        ageNumLabel.text = "\(Int(sender.value)) years"
    }
    
    
    @IBAction func AddDogInfoPressed(_ sender: UIButton) {
        // TODO: validate dog info before moving onto the next screen
        guard let name = nameTextField.text else {
            return
        }
        
        if name.isEmpty {
            alertUserRegisterError(message: "Please enter dog name to continue")
        } else {
            performSegue(withIdentifier: "DogInfoToDogBio", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DogInfoToDogBio" {
            let vc = segue.destination as! DogBioViewController
            vc.dogName = nameTextField.text
            vc.age = ageNumLabel.text
            vc.fixed = fixedSwitch.isOn
            if genderSelector.selectedSegmentIndex == 0{
                vc.gender = "Male"
            } else {
                vc.gender = "Female"
            }
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

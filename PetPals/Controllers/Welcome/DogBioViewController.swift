//
//  DogBioViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/14/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker
import JGProgressHUD

class DogBioViewController: UIViewController {

    @IBOutlet weak var image1View: UIImageView!
    @IBOutlet weak var image2View: UIImageView!
    @IBOutlet weak var image3View: UIImageView!
    @IBOutlet weak var image4View: UIImageView!
    
    @IBOutlet weak var aboutMeTextField: UITextField!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    var dogName: String?
    var age: String?
    var fixed: Bool?
    var gender: String?
    var aboutMe: String?
    var imagesList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectPhotoButton.layer.cornerRadius = 20
        finishButton.layer.cornerRadius = 20
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func selectPhotoTapped(_ sender: UIButton) {
        let imagePickerController = ImagePickerController()
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 4
        present(imagePickerController, animated: true)
    }
    
    @IBAction func finishButtonTapped(_ sender: UIButton) {
        aboutMe = aboutMeTextField.text
        
        guard let useremail = Auth.auth().currentUser?.email else {
            return
        }
        
        if imagesList.isEmpty {
            alertUserRegisterError(message: "Must select an image to continue")
            return
        }
        
        let imagesListData: [Data] = imagesList.map( { image in
            image.pngData()!
        })
        
        spinner.show(in: view)
        
        let imageGroup = DispatchGroup()
        var urls = [String]()
        var count = 0
        for image in imagesListData {
            count += 1
            let filename = "\(useremail)/photo_\(count).png"
            print("entered group")
            imageGroup.enter()
            StorageManager.shared.uploadPicture(with: image, filename: filename, completion: { success in
                if success {
                    StorageManager.shared.downloadPicture(from: filename, completion: { result in
                         switch result {
                         case .success(let downloadUrl):
                             urls.append(downloadUrl)
                         case .failure(let error):
                             print("Storage manager error: \(error)")
                         }
                         imageGroup.leave()
                     })
                }
                
            })
        }
        
        imageGroup.notify(queue: DispatchQueue.main) {
            UserDefaults.standard.set(urls, forKey: "images")
            
            guard let name = self.dogName,
                let about = self.aboutMe,
                let age = self.age,
                let gender = self.gender,
                let fixed = self.fixed else {
                    return
            }
            
            let newDog = Dog(name: name,
                             aboutMe: about,
                             age: age,
                             gender: gender,
                             fixed: fixed,
                             pics: urls,
                             userEmail: useremail
            )
            
            DatabaseManager().insertNewDog(with: newDog)
            self.spinner.dismiss(animated: true)
            self.performSegue(withIdentifier: "RegisterToHome", sender: self)
        }
    }
}

extension DogBioViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapper was pressed")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        // clear images
        image1View.image = nil
        image2View.image = nil
        image3View.image = nil
        image4View.image = nil
        
        imagesList = images
        imagePicker.dismiss(animated: true, completion: nil)
        
        // assign images where their displayed
        switch images.count {
        case 1:
            image1View.image = images[0]
        case 2:
            image1View.image = images[0]
            image2View.image = images[1]
        case 3:
            image1View.image = images[0]
            image2View.image = images[1]
            image3View.image = images[2]
        case 4:
            image1View.image = images[0]
            image2View.image = images[1]
            image3View.image = images[2]
            image4View.image = images[3]
        default:
            alertUserRegisterError(message: "Must select an image to continue")
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
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

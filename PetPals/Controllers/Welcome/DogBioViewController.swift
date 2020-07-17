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

class DogBioViewController: UIViewController {

    @IBOutlet weak var image1View: UIImageView!

    var dogName: String?
    var age: String?
    var aboutMe: String?
    var imagesList = [UIImage]()
    
    @IBOutlet weak var aboutMeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func selectPhotoTapped(_ sender: UIButton) {
        print("Select Photo tapped")
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 4
        present(imagePickerController, animated: true)
    }
    
    @IBAction func registerButtonTapeed(_ sender: UIButton) {
        aboutMe = aboutMeTextField.text
        
        
        
        let imagesListData: [Data] = imagesList.map( { image in
            image.pngData()!
        })
        
        guard let useremail = Auth.auth().currentUser?.email else {
            return
        }
        
        let imageGroup = DispatchGroup()
        var urls = [String]()
        var count = 0
        for image in imagesListData {
            count += 1
            let filename = "\(useremail)/photo_\(count).png"
            print("entered group")
            imageGroup.enter()
            StorageManager.shared.uploadPicture(with: image, filename: filename, completion: { result in
                switch result {
                case .success(let downlaodUrl):
                    urls.append(downlaodUrl)
                case .failure(let error):
                    print("Storage manager error: \(error)")
                }
                imageGroup.leave()
                print("left group")
            })
            
        }
        
        imageGroup.notify(queue: DispatchQueue.main) {
            UserDefaults.standard.set(urls, forKey: "images")
            
            guard let name = self.dogName,
                let about = self.aboutMe,
                let age = self.age else {
                return
            }
            
            let newDog = Dog(name: name,
                             aboutMe: about,
                             age: age,
                             userEmail: useremail
            )
            
            
            DatabaseManager().insertNewDog(with: newDog)
            
            self.performSegue(withIdentifier: "RegisterToHome", sender: self)
        }
    }
}

extension DogBioViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapper was pressed")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("done was pressed")
        print(images)
        
        imagesList = images
        image1View.image = images[0]
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("cancel was pressed")
    }
    
}

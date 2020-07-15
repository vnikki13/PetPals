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
        // only uploading image
        guard let image = image1View.image, let data = image.pngData() else {
            return
        }
        
        let useremail = Auth.auth().currentUser?.email
        let filename = "\(useremail!)_profile_picture.png"
        StorageManager.shared.uploadProfilePicture(with: data, filename: filename, completion: { result in
            switch result {
            case .success(let downlaodUrl):
                UserDefaults.standard.set(downlaodUrl, forKey: "profile_picture_url")
                print(downlaodUrl)
            case .failure(let error):
                print("Storage manager error: \(error)")
            }
        })
        
        let vc = HomeViewController()
        vc.title = "Home"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension DogBioViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapper was pressed")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("done was pressed")
        print(images)
        
        image1View.image = images[0]
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("cancel was pressed")
    }
    
    
}

//extension DogBioViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func presentCamera() {
//        let vc = UIImagePickerController()
//        vc.delegate = self
//        present(vc, animated: true, completion: nil)
//    }
//
//    func presentPhotoPicker() {
//        let vc = UIImagePickerController()
//        vc.sourceType = .photoLibrary
//        vc.delegate = self
//        present(vc, animated: true)
//    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//
//    }
//}

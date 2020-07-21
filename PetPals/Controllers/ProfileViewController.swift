//
//  ProfileViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/14/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase


class ProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var userInfo = [ProfileViewModel]()
    var dogInfo = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager().getDataForDog(email: userEmail, completion: { result in
            switch result {
            case .success(let doc):
                guard let name = doc.data()!["name"],
                    let age = doc.data()!["age"],
                    let gender = doc.data()!["gender"],
                    let fixed = doc.data()!["fixed"] as! Int?,
                    let bio = doc.data()!["bio"] else {
                        return
                }
                
                self.dogInfo.append(ProfileViewModel(
                    viewModelType: .info,
                    title: "Name: \(name)",
                    handler: nil)
                )
                
                self.dogInfo.append(ProfileViewModel(
                    viewModelType: .info,
                    title: "Age: \(age)",
                    handler: nil)
                )
                
                self.dogInfo.append(ProfileViewModel(
                    viewModelType: .info,
                    title: "Gender: \(gender)",
                    handler: nil)
                )
                
                self.dogInfo.append(ProfileViewModel(
                    viewModelType: .info,
                    title: "Bio: \(bio)",
                    handler: nil)
                )
                
                if fixed == 0 {
                    self.dogInfo.append(ProfileViewModel(
                        viewModelType: .info,
                        title: "Fixed: No",
                        handler: nil)
                    )
                } else {
                    self.dogInfo.append(ProfileViewModel(
                        viewModelType: .info,
                        title: "Fixed: Yes",
                        handler: nil)
                    )
                }
                
                self.tableView.reloadData()
                
            case .failure(let err):
                print("Could not find documentation: \(err)")
            }
        })
        
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        userInfo.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(UserDefaults.standard.value(forKey:"firstName") as? String ?? "No Name")",
            handler: nil))
        userInfo.append(ProfileViewModel(viewModelType: .info,
                                     title: "Email: \(UserDefaults.standard.value(forKey:"email") as? String ?? "No Email")",
            handler: nil))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = true
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 300))
        
        let imageView = UIImageView(frame: CGRect(x: 10,
                                                  y: 10,
                                                  width: self.view.width - 20,
                                                  height: 300 - 20))
        headerView.backgroundColor = #colorLiteral(red: 1, green: 0.9183339477, blue: 0.8591601849, alpha: 1)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/20
        headerView.addSubview(imageView)
        
        navigationItem.title = "Profile"
        
        let path = "images/\(email)/photo_1.png"
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        return headerView
    }

    @IBAction func LogOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(nil, forKey: "firstName")
            UserDefaults.standard.set(nil, forKey: "email")
            
            performSegue(withIdentifier: "UnwindToWelcome", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userInfo.count
        }
        return dogInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier,
                                                 for: indexPath) as! ProfileTableViewCell
        
        let viewModel = indexPath.section == 0 ? userInfo[indexPath.row] : dogInfo[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.setUp(with: viewModel)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        if section == 0 {
            label.text = "User"
        } else {
            label.text = "Dog"
        }
        
        label.textAlignment = .center
        label.font = label.font.withSize(25)
        label.textColor = #colorLiteral(red: 0.4039215686, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
        return label
    }
}

//
//  DetailsPageViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/16/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class DetailsPageViewController: UIViewController {

    let dog: Dog
    let dogOwner = String()
    
    init(with model: Dog) {
        self.dog = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let table: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(DetailsPageCollectionTableViewCell.self, forCellReuseIdentifier: DetailsPageCollectionTableViewCell.identifier)
        return table
    }()
    
    private var models = [CellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        
        setUpModels()
        
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
    }
    
    @objc private func didTapComposeButton() {
        DatabaseManager().getDataForUser(email: dog.userEmail, completion: { result in
            switch result {
            case .success(let info):
                guard let name = info as? String else {
                    return
                }
                
                let vc = ChatViewController(email: self.dog.userEmail, id: nil, name: name)
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(let error):
                print("unable to find user: \(error)")
                return
            }
            
            
        })
    }
    
    private func setUpModels() {
        DatabaseManager().getDataForUser(email: dog.userEmail, completion: { result in
            switch result {
            case .success(let data):
                guard let firstName = data as? String else {
                    return
                }
                print(firstName)
                
            case .failure(let error):
                print(error)
            }
        })
        
        let modelCollection = self.dog.pics.sorted().map({ (pic: String) -> CollectionTableCellModel in
            return CollectionTableCellModel(imageName: pic)
        })
        
        self.models.append(.collectionView(models: modelCollection, rows: 1))
        
        self.models.append(.list(models: [
            ListCellModel(title: self.dog.aboutMe),
            ListCellModel(title: self.dog.age + " old"),
            ListCellModel(title: self.dog.gender),
        ]))
        
        if self.dog.fixed {
            self.models.append(.list(models: [
                ListCellModel(title: "I am fixed")
            ]))
        } else {
            self.models.append(.list(models: [
                ListCellModel(title: "I am not fixed")
            ]))
        }
        
        self.models.append(.list(models: [
            ListCellModel(title: "Owner: " ),
        ]))
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }

}

extension DetailsPageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch models[section] {
        case .list(let models):
            return models.count
        case .collectionView(_, _):
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch models[indexPath.section] {
        case .list(let models):
            let model = models[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = model.title
            cell.textLabel?.numberOfLines = 0
            cell.isUserInteractionEnabled = false
            return cell
            
        case .collectionView(let models, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailsPageCollectionTableViewCell.identifier,
                                                     for: indexPath) as! DetailsPageCollectionTableViewCell
            cell.configure(with: models)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch models[indexPath.section] {
        case .list(_):
            return 50
        case .collectionView(_, let rows):
            return 350 * CGFloat(rows)
        }
    }
    
    
}

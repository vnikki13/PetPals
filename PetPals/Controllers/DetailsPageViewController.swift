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
    
    init(with model: Dog) {
        self.dog = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let detailsPageTable = UITableView()
    
    private let table: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = UITableViewCell.SeparatorStyle.none
        let nib = UINib(nibName: DetailsPageTableViewCell.identifier, bundle: nil)
        table.register(nib, forCellReuseIdentifier: DetailsPageTableViewCell.identifier)
        table.register(DetailsPageCollectionTableViewCell.self,
                       forCellReuseIdentifier: DetailsPageCollectionTableViewCell.identifier)
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
                guard let name = data as? String else {
                    return
                }
                
                self.models.append(.list(models: [
                    ListCellModel(title: "Owner: \(name)" ),
                ]))
                
                self.table.reloadData()
                
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
            ListCellModel(title: "Age: \(self.dog.age) old"),
            ListCellModel(title: "Sex: \(self.dog.gender)"),
        ]))
        
        if self.dog.fixed {
            self.models.append(.list(models: [
                ListCellModel(title: "Fixed: Yes")
            ]))
        } else {
            self.models.append(.list(models: [
                ListCellModel(title: "Fixed: No")
            ]))
        }
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailsPageTableViewCell.identifier, for: indexPath) as! DetailsPageTableViewCell
            cell.cellView.layer.cornerRadius = 10
            cell.descriptionLabel.text = model.title
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
            return UITableView.automaticDimension
        case .collectionView(_, let rows):
            return 350 * CGFloat(rows)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
}

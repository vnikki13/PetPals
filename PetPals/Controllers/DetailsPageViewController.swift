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
    
    private let table: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(DetailsPageCollectionTableViewCell.self, forCellReuseIdentifier: DetailsPageCollectionTableViewCell.identifier)
        return table
    }()
    
    private var models = [CellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpModels()
        
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
    }
    
    private func setUpModels() {
        // TODO: save urls to each dogs profile in database
        // Replace UserDefaults (which is the current logged in user)
        // with dog.photos
        
        let dogPics = UserDefaults.standard.value(forKey: "images") as! [String]
        
        let modelCollection = dogPics.map({ (pic: String) -> CollectionTableCellModel in
            return CollectionTableCellModel(imageName: pic)
        })

        models.append(.collectionView(models: modelCollection, rows: 1))
        
//        models.append(.collectionView(models: [
//            CollectionTableCellModel(imageName: "Image"),
//            CollectionTableCellModel(imageName: "Image"),
//            CollectionTableCellModel(imageName: "Image"),
//            CollectionTableCellModel(imageName: "Image"),
//            CollectionTableCellModel(imageName: "Image"),
//            CollectionTableCellModel(imageName: "Image"),
//            CollectionTableCellModel(imageName: "Image")
//        ], rows: 1))
        
        models.append(.list(models: [
            ListCellModel(title: "First Thing"),
            ListCellModel(title: "First Thing"),
            ListCellModel(title: "First Thing"),
            ListCellModel(title: "First Thing"),
            ListCellModel(title: "First Thing")
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
            return cell
            
        case .collectionView(let models, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailsPageCollectionTableViewCell.identifier,
                                                     for: indexPath) as! DetailsPageCollectionTableViewCell
            cell.configure(with: models)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

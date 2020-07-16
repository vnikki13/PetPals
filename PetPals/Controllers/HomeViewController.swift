//
//  HomeViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    private var dogs = [Dog]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(DogTableViewCell.self,
                       forCellReuseIdentifier: DogTableViewCell.identifier)
        return table
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        setupTableView()
        fetchDogs()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func validateAuth() {
        if Auth.auth().currentUser == nil {
            print("trying to perform seque")
            performSegue(withIdentifier: "HomeToLogin", sender: self)
            tabBarController?.hidesBottomBarWhenPushed = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchDogs() {
        DatabaseManager().getAllDogs(completion: { result in
            switch result {
            case .success(let dogs):
                print("got all dogs: \(dogs)")
                self.dogs = dogs
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get dogs: \(error)")
            }
        })
    }
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(dogs.count)
        return dogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dogs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: DogTableViewCell.identifier,
                                                 for: indexPath) as! DogTableViewCell
        // TODO: make sure users are not nil
        cell.configure(with: model)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dogs[indexPath.row]
        openDetailsPage(model)
    }

    func openDetailsPage(_ model: Dog) {
        let vc = DetailsPageViewController()
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }
}

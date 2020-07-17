//
//  DogsViewController.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/16/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import Firebase

class DogsViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    private var dogs = [Dog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        collectionView.collectionViewLayout = layout
        
        collectionView.register(DogsCollectionViewCell.nib(), forCellWithReuseIdentifier: DogsCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchDogs()
    }
    
    private func fetchDogs() {
        DatabaseManager().getAllDogs(completion: { result in
            switch result {
            case .success(let dogs):
                print("got all dogs: \(dogs)")
                self.dogs = dogs
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get dogs: \(error)")
            }
        })
    }

}

extension DogsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let model = dogs[indexPath.row]
        openDetailsPage(model)
    }
    
    func openDetailsPage(_ model: Dog) {
        let vc = DetailsPageViewController(with: model)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)

    }
}

extension DogsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = dogs[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DogsCollectionViewCell.identifier, for: indexPath) as! DogsCollectionViewCell

        cell.configure(with: model)

        return cell
    }
    
    
}

extension DogsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}

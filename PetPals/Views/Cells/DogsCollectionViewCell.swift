//
//  DogsCollectionViewCell.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/16/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit
import SDWebImage

class DogsCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    static let identifier = "DogsCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "DogsCollectionViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with model: Dog) {
        nameLabel.text = model.name
        
        let path = "images/\(model.userEmail)/photo_1.png"
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {

                    self?.imageView.sd_setImage(with: url, completed: nil)
                }

            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
    
    }

}

//
//  DetailsPageTableCollectionViewCell.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/16/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class DetailsPageTableCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "DetailsPageTableCollectionViewCell"
    
    public let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: contentView.width,
                                 height: contentView.height)
        
    }
    
    public func configure(with model: CollectionTableCellModel) {
        guard let url = URL(string: model.imageName) else {
            return
        }
        
        DispatchQueue.main.async {
            self.imageView.sd_setImage(with: url, completed: nil)
        }
    }
}

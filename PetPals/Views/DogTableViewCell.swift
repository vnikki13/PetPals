//
//  DogTableViewCell.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/15/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class DogTableViewCell: UITableViewCell {

    static let identifier = "DogTableViewCell"
    
    private let dogImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let dogNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dogImageView)
        contentView.addSubview(dogNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        dogImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)

        dogNameLabel.frame = CGRect(x: dogImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - dogImageView.width,
                                     height: (contentView.height-20)/2)

    }
    
    public func configure(with model: Dog) {
        dogNameLabel.text = model.name
    }

}


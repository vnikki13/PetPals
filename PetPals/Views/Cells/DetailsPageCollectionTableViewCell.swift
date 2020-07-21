//
//  DetailsPageCollectionTableViewCell.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/16/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import UIKit

class DetailsPageCollectionTableViewCell: UITableViewCell {
    
    static let identifier = "DetailsPageCollectionTableViewCell"
    
    private var models = [CollectionTableCellModel]()
    
    private let collectionView: UICollectionView
    
    private lazy var imagePageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = .gray
        return pc
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let width = UIScreen.main.fixedCoordinateSpace.bounds.width
        let height = UIScreen.main.fixedCoordinateSpace.bounds.height
        
        layout.itemSize = CGSize(width: width, height: height)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(DetailsPageTableCollectionViewCell.self, forCellWithReuseIdentifier: DetailsPageTableCollectionViewCell.identifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubview(collectionView)
        contentView.addSubview(imagePageControl)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let x = targetContentOffset.pointee.x
        
        imagePageControl.currentPage = Int(x / contentView.frame.width)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
        imagePageControl.frame = CGRect(x: (contentView.width/2) - 100, y: contentView.height - 40, width: contentView.width/2, height: 30)
        imagePageControl.numberOfPages = models.count
    }
    
    public func configure(with models: [CollectionTableCellModel]) {
        self.models = models
        collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension DetailsPageCollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailsPageTableCollectionViewCell.identifier, for: indexPath) as! DetailsPageTableCollectionViewCell

        cell.configure(with: model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt Selection: Int) -> UIEdgeInsets { return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt selection: Int) -> CGFloat{ return 0 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt selection: Int) -> CGFloat{ return 0 }
}

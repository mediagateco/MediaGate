//
//  ProfileRollerTableViewCell.swift
//  MediaGate
//
//  Created by Nouha Nouman on 21/03/2020.
//  Copyright © 2020 Nouha Nouman. All rights reserved.
//

import UIKit
import Firebase

class ProfileRollerTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //collectionView.registerNibForCollection(ofType: productItem.self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func setCollectionViewDelegate<D: UICollectionViewDelegate &
        UICollectionViewDataSource>(delegate: D, forRow row: Int) {
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        collectionView.tag = row
        
        collectionView.reloadData()

    }
}


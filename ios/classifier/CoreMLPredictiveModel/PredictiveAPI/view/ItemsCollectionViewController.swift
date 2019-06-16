//
//  ItemsCollectionViewController.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 2/13/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit

final class ItemsCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    var items:[UserRecord] = [UserRecord]()
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
     private let itemsPerRow: CGFloat = 1
    
    
    private func registerCells() {
        let itemNib = UINib(nibName: "CustomImageCollectionViewCell", bundle: Bundle.main)
        self.collectionView?.register(itemNib, forCellWithReuseIdentifier: "ItemCell")
        
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Matching Items in Category", comment: "")
        self.registerCells()
        
        
    }
  
    
}


// MARK: - UICollectionViewDataSource
extension ItemsCollectionViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "ItemCell", for: indexPath) as? CustomImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.row]
        
        if let imageData = item.photo{
            cell.imageBlob  = UIImage.init(data: imageData)
            cell.label = item.tag
        }
        else {
            cell.imageBlob  = UIImage.init(imageLiteralResourceName: "default-user-thumbnail")
        }
        
        return cell
        
    }
}

// MARK: - Collection View Flow Layout Delegate
extension ItemsCollectionViewController : UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
 
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


// MARK: IBActions
extension ItemsCollectionViewController {
    @IBAction func onDoneTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            
        }
        
    }
    
    
}

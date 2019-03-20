//
//  CustomImageCollectionViewCell.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 2/13/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class CustomImageCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    
    
    var imageBlob:UIImage? {
        didSet {
            updateUI()
        }
    }
    private let defaultLabel = "Unknown"
    public var label:String? {
        didSet {
            self.updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateUI()
        
    }
    
 
    
    private func updateUI(){
        if let _ = imageView, let imageVal = imageBlob {
            self.imageView.image = imageVal
        }
        if let _ = label, let label = label {
            self.imageLabel.text = label
        }
        else {
            self.imageLabel.text = defaultLabel
        }
        
        self.layoutIfNeeded()
    }
 
    
}

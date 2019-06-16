//
//  CustomImageEntryTableViewCell.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/11/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit


protocol CustomImageEntryTableViewCellProtocol:class {
    func onUploadImage()
    
}

// optional
extension CustomImageEntryTableViewCellProtocol {
    func onUploadImage() {
        print(#function)
    }
}

class CustomImageEntryTableViewCell: UITableViewCell {
    var imageBlob:UIImage? {
        didSet {
            updateUI()
        }
    }
    var uploadButton:UIButton?
    weak var delegate:CustomImageEntryTableViewCellProtocol?
    
    @IBOutlet weak var imageEntryView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateUI()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func updateUI(){
        if let _ = imageEntryView, let imageVal = imageBlob {
            self.imageEntryView.image = imageVal
        }
        
        self.layoutIfNeeded()
    }
    
}

extension CustomImageEntryTableViewCell {
    @IBAction func updateThumbnail(_ sender: UIButton) {
        delegate?.onUploadImage()
        
    }
}

//
//  CustomTextEntryTableViewCell.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/11/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit

class CustomTextEntryTableViewCell: UITableViewCell {
    
    private let defaultName = NSLocalizedString("item", comment: "default item name") 
    public var name:String? {
        didSet {
            self.updateUI()
        }
    }
    
    @IBOutlet weak var textEntryName: UILabel!
    @IBOutlet weak var textEntryValue: UITextView!
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
        if let _ = textEntryName, let name = name {
            self.textEntryName.text = name
        }
        else {
            self.textEntryName.text = defaultName
        }
        self.layoutIfNeeded()
    }
    
}

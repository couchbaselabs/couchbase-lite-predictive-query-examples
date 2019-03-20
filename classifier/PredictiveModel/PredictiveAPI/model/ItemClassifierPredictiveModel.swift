//
//  OpenFacePredictiveModel.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/11/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift
let kPredictionCategory = "category"
let kPredictionProbability = "probability"
class ItemClassifierPredictiveModel:PredictiveModel {
    class var name: String {
        return "ItemClassifier"
    }
    
    
    var itemClassifierService:ItemClassifierService = ItemClassifierService()
    
    func predict(input: DictionaryObject) -> DictionaryObject? {
        // Expect that this is invoked with image
        let utils = FileUtils.init()
        if let imageData = input.blob(forKey: UserRecordDocumentKeys.photo.rawValue)?.content {
            if var image = UIImage.init(data: imageData) {
               
                print("image size = \(image.size)")
                if let result = itemClassifierService.runItemClassifierModelOnImage(image) {
                    let modifiedResult:[String?:Any?] = [ kPredictionCategory: result.first?.key as? String, kPredictionProbability: result.first?.value as? Double]
                    return MutableDictionaryObject(data: [UserRecordDocumentKeys.photo.rawValue:modifiedResult])
                }
            }
        }
        
        return nil
    }
    
    func registerModel() {
        Database.prediction.registerModel(self, withName: type(of: self).name)
    }
    
    func unregisterModel() {
        Database.prediction.unregisterModel(withName: type(of: self).name)
    }
    
}


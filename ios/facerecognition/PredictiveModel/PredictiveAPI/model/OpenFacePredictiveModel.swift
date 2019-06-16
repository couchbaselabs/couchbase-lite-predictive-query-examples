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

class OpenFacePredictiveModel:PredictiveModel {
    class var name: String {
        return "OpenFace"
    }
    
    var faceRecognitionService:FaceRecognizer = FaceRecognizer()
    
    func predict(input: DictionaryObject) -> DictionaryObject? {
        // Expect that this is invoked with image
        let utils = FileUtils.init()
        if let imageData = input.blob(forKey: UserRecordDocumentKeys.photo.rawValue)?.content {
            if var image = UIImage.init(data: imageData) {
                
                if let result = faceRecognitionService.runOpenFaceModelOnImage(image) {
                    return MutableDictionaryObject(data: [UserRecordDocumentKeys.photo.rawValue:result])
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

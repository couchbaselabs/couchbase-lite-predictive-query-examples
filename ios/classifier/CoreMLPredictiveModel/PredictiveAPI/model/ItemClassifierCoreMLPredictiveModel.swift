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
import CoreML
let kPredictionCategory = "label"
let kPredictionProbability = "labelProbability"

class ItemClassifierCoreMLPredictiveModel {
    class var name: String {
        return "ItemClassifier"
    }

    enum outFeatureNames:String {
        case kPredictionCategory = "label"
        case kPredictionProbability = "labelProbability"
    }
    
    var inputFeatureNames:[String] = ["image"] // Just get this from the OpenFace model description
    
    static let SharedInstance:ItemClassifierCoreMLPredictiveModel = {
        let instance = ItemClassifierCoreMLPredictiveModel()
        return instance
        
    }()
    
    var model:MLModel {
        return ItemClassifier.init().model
        
    }
    
    // Don't allow instantiation . Enforce singleton
    private init() {
        
    }
    
}


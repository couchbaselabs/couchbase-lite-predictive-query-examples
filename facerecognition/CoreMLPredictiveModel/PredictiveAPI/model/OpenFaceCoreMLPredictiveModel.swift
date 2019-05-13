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
class OpenFaceCoreMLPredictiveModel {
    class var name: String {
        return "OpenFace"
    }
    
    var inputFeatureNames:[String] = ["data"] // Just get this from the OpenFace model description
    static let SharedInstance:OpenFaceCoreMLPredictiveModel = {
        let instance = OpenFaceCoreMLPredictiveModel()
        return instance
        
    }()
    
    var model:MLModel {
        return OpenFace.init().model
      
    }
   
    // Don't allow instantiation . Enforce singleton
    private init() {
        
    }
}

//
//  FaceRecognizer.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/10/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import UIKit
import CoreML

final class ItemClassifierService {
    let model:ItemClassifier = ItemClassifier.init()
 
    
    func runItemClassifierPredictionOnInput(_ input:ItemClassifierInput)->ItemClassifierOutput? {
       
         do {
            let prediction = try model.prediction(input:input)
            return prediction

        }
        catch {
            print (error)
            return nil
        }

    }
    
    func runItemClassifierPredictionOnInputs(_ inputs:[ItemClassifierInput])->[ItemClassifierOutput]? {
        
        do {
            let predictions = try model.predictions(inputs: inputs)
            return predictions
            
        }
        catch {
            print (error)
            return nil
        }
        
    }
}

extension ItemClassifierService {
    
    func runItemClassifierModelOnImage(_ image:UIImage)->[String?:Double?]? {
        var resizedImage = image
        if image.size.width != 224.0 || image.size.height != 224.0 {
            resizedImage = FileUtils.init().resize(image: image, newWidth: 224.0, newHeight: 224.0)
            
        }
        
        guard let buffer = ItemClassifierUtil.cvpBuffer(from:resizedImage) else {
            return nil
        }
        do {
            let prediction = try model.prediction(image: buffer)
            return [prediction.label:prediction.labelProbability[prediction.label]]
            
        }
        catch {
            print (error)
            return nil
        }
        
    }
    
    func runItemClassifierModelOnImages(_ images:[UIImage])->[[String?:Double?]]? {
        var inputs:[ItemClassifierInput] = [ItemClassifierInput]()
        for image in images {
            guard let buffer = ItemClassifierUtil.cvpBuffer(from:image) else {
                return nil
            }
            let input = ItemClassifierInput.init(image: buffer)
            inputs.append(input)
        }
        
        do {
            
            let predictions = try model.predictions(inputs: inputs)
            var outputs = [[String?:Double?]]()
            for prediction in predictions {
                
                outputs.append([prediction.label:prediction.labelProbability[prediction.label]])
                return outputs
            }
        }
        catch {
            print (error)
            return nil
        }
        return nil
    }
    
}

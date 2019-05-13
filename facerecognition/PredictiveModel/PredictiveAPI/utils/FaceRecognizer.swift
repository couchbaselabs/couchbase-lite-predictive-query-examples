//
//  FaceRecognizer.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/10/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import UIKit
import CoreML
import Vision

final class FaceRecognizer {
    fileprivate let model:OpenFace = OpenFace.init()
    
    
    func runOpenFacePredictionOnOpenFaceInput(_ input:OpenFaceInput)->OpenFaceOutput? {
       
         do {
            let prediction = try model.prediction(input:input)
            return prediction

        }
        catch {
            print (error)
            return nil
        }

    }
    
    func runOpenFacePredictionOnOpenFaceInputs(_ inputs:[OpenFaceInput])->[OpenFaceOutput]? {
        
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

extension FaceRecognizer {
    
    func runOpenFaceModelOnImage(_ image:UIImage)->[Double]? {
        // OpenFace expects image in 96 X 96 format. So resize accordingly
        var resizedImage = image
        
        if image.size.width != 96.0 || image.size.height != 96.0 {
            resizedImage = FileUtils.init().resize(image: image, newWidth: 96.0, newHeight: 96.0)
            
        }
        guard let buffer = OpenFaceUtil.cvpBuffer(from:resizedImage) else {
            return nil
        }
        do {
            let prediction = try model.prediction(data: buffer)
            let vectorOutput = prediction.output
            
            let doublePtr =  vectorOutput.dataPointer.bindMemory(to: Double.self, capacity: vectorOutput.count)
            let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: vectorOutput.count)
            let output = Array(doubleBuffer)
            
            return output
            
        }
        catch {
            print (error)
            return nil
        }
        
    }
    
    func runOpenFaceModelOnImages(_ images:[UIImage])->[[Double]]? {
        var inputs:[OpenFaceInput] = [OpenFaceInput]()
        var outputs:[[Double]] = [[Double]()]
        for image in images {
            guard let buffer = OpenFaceUtil.cvpBuffer(from:image) else {
                return nil
            }
            let input = OpenFaceInput.init(data: buffer)
            inputs.append(input)
        }
        
        do {
            
            let predictions = try model.predictions(inputs: inputs)
            for prediction in predictions {
                let vectorOutput = prediction.output
                
                let doublePtr =  vectorOutput.dataPointer.bindMemory(to: Double.self, capacity: vectorOutput.count)
                let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: vectorOutput.count)
                let output = Array(doubleBuffer)
                outputs.append(output)
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

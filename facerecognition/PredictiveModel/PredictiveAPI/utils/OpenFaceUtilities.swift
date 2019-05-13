//
//  Utilities.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/10/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreML

final class OpenFaceUtil {
// Image to Picel Buffer Conversion
 static func cvpBuffer(from image: UIImage) -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
        return nil
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    context?.translateBy(x: 0, y: image.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    
    UIGraphicsPushContext(context!)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    return pixelBuffer!
}


// Conversions from Image type to OpenFaceInput
static func imageToOpenFaceInput(_ image:UIImage)->OpenFaceInput? {
    guard let buffer = cvpBuffer(from:image) else {
        return nil
    }
    return OpenFaceInput.init(data: buffer)
}

static func imagesToOpenFaceInputs(_ images:[UIImage])->[OpenFaceInput]? {
    var inputs:[OpenFaceInput] = [OpenFaceInput]()
    for image in images {
        if let input = imageToOpenFaceInput(image) {
            inputs.append(input)
        
        }
    }
    return inputs
}

// Conversions from OpenFaceOutput to Swift Double array
static func openFaceOutputToDoubleVector(_ output:OpenFaceOutput)->[Double] {
    let vectorOutput = output.output
    let doublePtr =  vectorOutput.dataPointer.bindMemory(to: Double.self, capacity: vectorOutput.count)
    let doubleBuffer = UnsafeBufferPointer(start: doublePtr, count: vectorOutput.count)
    return Array(doubleBuffer)
}

static func openFaceOutputsToDoubleVectors(_ outputs:[OpenFaceOutput])->[[Double]] {
    
    var doubleOutputs = [[Double]()]
    for output in outputs {
        let out = openFaceOutputToDoubleVector(output)
        doubleOutputs.append(out)
        
    }
   return doubleOutputs
}

}

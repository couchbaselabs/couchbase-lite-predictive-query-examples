//
//  Utilities.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/10/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//
////////////// This class is currently not in use in app //////////////////////////////////////
import Foundation
import UIKit
import CoreML

final class ItemClassifierUtil {
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


// Conversions from Image type to ItemClassifierInput
static func imageToItemClassifierInput(_ image:UIImage)->ItemClassifierInput? {
    
    guard let buffer = cvpBuffer(from:image) else {
        return nil
    }
    return ItemClassifierInput.init(image: buffer)
}

static func imagesToItemClassifierInputs(_ images:[UIImage])->[ItemClassifierInput]? {
    var inputs:[ItemClassifierInput] = [ItemClassifierInput]()
    for image in images {
        if let input = imageToItemClassifierInput(image) {
            inputs.append(input)
        
        }
    }
    return inputs
}

// Conversions from OpenFaceOutput to Swift Double array
static func itemClassifierOutputToStringOutput(_ output:ItemClassifierOutput)->String {
    return output.label
}

static func itemClassifierOutputsToStringVector(_ outputs:[ItemClassifierOutput])->[String] {
    
        var stringOutputs = [String()]
        for output in outputs {
            let out = itemClassifierOutputToStringOutput(output)
            stringOutputs.append(out)
        }
        return stringOutputs
    }

}

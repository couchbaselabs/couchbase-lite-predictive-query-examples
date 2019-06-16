//
//  FileUtils.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/11/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit
class FileUtils {


func loadImageFilesFromFolder(_ folder:String)->[String:[UIImage]] {
    var files:[String:[UIImage]] = [String:[UIImage]]()
    let bundle = Bundle(for: type(of: self))
    let path = bundle.bundlePath
    let newPath = path.appending("/\(folder)")
    let enumerator = FileManager.default.enumerator(atPath:newPath)
    while let element = enumerator?.nextObject() as? String {
        if(enumerator?.fileAttributes?[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeRegular){
            
            if let data = UIImage(contentsOfFile: newPath.appending("/\(element)")) {
                //openface needs this size
                print("filename is \(element)")
                if let last = element.components(separatedBy: "/").last, let first = element.components(separatedBy: "/").first {
                    let resizedData = resize(image: data, newWidth: 224.0, newHeight: 224.0)
                    
                   print("first \(first)")
                   print("Last is \(last)")
                    files[first]?.append(resizedData)
                }
            }
            
        }
        else if(enumerator?.fileAttributes?[FileAttributeKey.type] as! FileAttributeType == FileAttributeType.typeDirectory){
            print("Label is \(element)")
            files[element] = [UIImage]()
        }
    }
    print("Loaded \(files.count) images")
    return files
}
    

    func resize(image: UIImage, newWidth: CGFloat,newHeight: CGFloat) -> UIImage {
        return RBResizeImage(image: RBSquareImage(image: image), newWidth:newWidth, newHeight: newHeight)
    }
    
    func RBSquareImage(image: UIImage) -> UIImage {
        var originalWidth  = image.size.width
        var originalHeight = image.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0
        
        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0
            
        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }
        
        let cropSquare = CGRect(x: x, y: y, width: edge, height: edge)
        var imageRef = image.cgImage?.cropping(to: cropSquare)
        
        
        return UIImage(cgImage: imageRef as! CGImage, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    
    func RBResizeImage(image: UIImage, newWidth: CGFloat,newHeight: CGFloat) -> UIImage {
        let size = image.size
        
        let widthRatio  = newWidth / image.size.width
        let heightRatio = newHeight / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
             newSize = CGSize(width:size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width:size.width * widthRatio,  height:size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat,newHeight: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}

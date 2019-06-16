//
//  CustomErrors.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/13/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
enum CustomError: LocalizedError , CustomStringConvertible{
   
    
    case DatabaseNotInitialized
    case InvalidParameters
    case DataParseError
    case ImageProcessingFailure
    case ImageTooBig
    
    
}

extension CustomError {
    var description: String {
        switch self {
        case .DatabaseNotInitialized :
            return NSLocalizedString("Couchbase Lite Database not initialized", comment: "")
        case .DataParseError:
            return NSLocalizedString("Could not parse response. Appears to be in invalid format ", comment: "")
        case .InvalidParameters:
            return NSLocalizedString("Parameters are not valid ", comment: "")
        case .ImageProcessingFailure:
            return NSLocalizedString("Failed to process image ", comment: "")
        case .ImageTooBig:
            return NSLocalizedString("Image size too big!", comment: "")
        }
    }
        
}

extension LocalizedError where Self: CustomStringConvertible {
    var errorDescription: String? {
            return description
    }
}

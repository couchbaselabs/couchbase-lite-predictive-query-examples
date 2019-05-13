//
//  UserRecord.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/11/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import UIKit

// tag::userrecord[]
let kUserRecordDocumentType = "item"
typealias ExtendedData = [[String:Any]]
struct UserRecord : CustomStringConvertible{
    let type = kUserRecordDocumentType
    var name:String?
    var photo:Data?
    var extended:[String:Any]? // future
    
    var description: String {
        return "name = \(String(describing: name)), photo = \(String(describing: photo))"
    }
    
}
// end::userrecord[]

//
//  DatabaseManager.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/10/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//


import Foundation
import UIKit
import CouchbaseLiteSwift

enum VectorDistanceType {
    case Cosine
    case Euclidien
    case SquaredEuclidien
}
class DatabaseManager {
    
    // public
    static let shared:DatabaseManager = {
        
        let instance = DatabaseManager()
       
        return instance
    }()

    
    var db:Database? {
        get {
            return _db
        }
    }
    
    var docsLoaded:Bool {
        return _docsLoaded
    }
    var dbChangeListenerToken:ListenerToken?
    var lastError:Error?
    
    // Internal
    fileprivate let kPrebuiltDBName:String = "faces"
    fileprivate let kPrebuiltDBFolder:String = "prebuilt"
    fileprivate var _db:Database?
    fileprivate var _docsLoaded:Bool = false
    
    fileprivate var _applicationDocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    fileprivate var _applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    
    // predictions
    fileprivate var coreMLPredictiveModel = {
        return CoreMLPredictiveModel(mlModel: OpenFaceCoreMLPredictiveModel.SharedInstance.model)
    }()
    

    func initialize() {
        enableCrazyLevelLogging()
    }
    // Don't allow instantiation . Enforce singleton
    private init() {
        
    }
    
    deinit {
        // Stop observing changes to the database that affect the query
        do {
            self.deregisterForDatabaseChanges()
            deregisterPredictionModel()
            try self._db?.close()
        }
        catch  {
            
        }
    }
    
}


// MARK: Predictive Queries Related
extension DatabaseManager {
  
    func registerPredictionModel() {
        print(#function)
        Database.prediction.registerModel(coreMLPredictiveModel, withName: OpenFaceCoreMLPredictiveModel.name)
    }
    
    
    
    func deregisterPredictionModel() {
        print(#function)
        Database.prediction.unregisterModel(withName: OpenFaceCoreMLPredictiveModel.name)
     }
    
    func createPredictiveIndexOnProperties(_ properties:[String])->Bool  {
        print(#function)

    // For searches on type property
        guard let db = db else {
            print ("Database is not initialized")
            return false
        }
        let model = OpenFaceCoreMLPredictiveModel.name
        guard let propName = properties.first else {
            return false
        }
        // TODO : How to use multiple properties
        let featureName = OpenFaceCoreMLPredictiveModel.SharedInstance.inputFeatureNames[0]
        let input = Expression.value([featureName: Expression.property(propName)])
        
        let index = IndexBuilder.predictiveIndex(model: model, input: input)
        do {
            try db.createIndex(index, withName: "\(propName)Index")
            return true
        }
        catch {
            print (error)
            return false
        }
    }
    
    
    func findDistanceBetweenPrediction(_ prediction1:ExpressionProtocol, prediction2:ExpressionProtocol, type:VectorDistanceType)->ExpressionProtocol {
          print(#function)
        switch type {
        case .Cosine :
            return Function.cosineDistance(between: prediction1, and: prediction2)
            
        case .Euclidien:
            return Function.euclideanDistance(between: prediction1, and: prediction2)
            
        case .SquaredEuclidien:
            return Function.euclideanDistance(between: prediction1, and: prediction2)
            
        }
    }
   
 
}

//MARK: Prediction Similarity/ Distance
extension DatabaseManager {
    
    func useRegisteredModelToFindClosestMatchesInDBToInputImage(_ imageData:Data, imageName:String, propertyName:String)->(userRecords:[UserRecord]?,status:Bool) {
          print(#function)
        guard let db = db else {
            fatalError("Database not initialized")
            return (nil,false)
        }
        let start1 = DispatchTime.now()
      
        let modelName = OpenFaceCoreMLPredictiveModel.name
        
        // Fingerprint of input image
        let inputImageFeatureName = OpenFaceCoreMLPredictiveModel.SharedInstance.inputFeatureNames[0]
        let inputPhotoParam = Expression.dictionary([inputImageFeatureName : Expression.parameter(imageName)])
        let fingerPrint1 = Function.prediction(model: modelName, input: inputPhotoParam).property("output")
                
        // Fingerprints of images in database
        let photoInDB = Expression.dictionary([inputImageFeatureName : Expression.property(propertyName)]);
        let fingerPrint2 = Function.prediction(model: modelName, input: photoInDB).property("output")
        
        // Find Distance between input image and images in database
        let distance = findDistanceBetweenPrediction(fingerPrint1 ,prediction2: fingerPrint2 ,type: .SquaredEuclidien)
     //   print("Distance is \(distance)")
        let end1 = DispatchTime.now()
        let nanoTime1 = end1.uptimeNanoseconds - start1.uptimeNanoseconds
        let timeInterval1 = Double(nanoTime1) / 1_000_000_000
       // print("Time to finding distance is \(timeInterval1) seconds")
        
        let start2 = DispatchTime.now()
       
        
        let query = QueryBuilder
            .select(SelectResult.all(),SelectResult.expression(distance))
            .from(DataSource.database(db))
            .orderBy(Ordering.expression(distance).ascending())
            .limit(Expression.int(1))
        
        // Set input parameters for query
        let params = Parameters()
        params.setBlob(Blob.init(contentType: "image/jpg", data: imageData), forName: imageName)
        query.parameters = params
        
        
        // Execute query
      //  print(try? query.explain())
        var results:[UserRecord] = [UserRecord]()
        
        do {
            
            var count = 0
            var num = 0
            for result in try query.execute() {
                if count == 0 {
                    let end2 = DispatchTime.now()
                    let nanoTime2 = end2.uptimeNanoseconds - start2.uptimeNanoseconds
                    let timeInterval2 = Double(nanoTime2) / 1_000_000_000
                    print("Time to query matching images in database is \(timeInterval2) seconds")
                    
                    count = count + 1
                }
                
                let resultVal = result.dictionary(forKey: "faces")
                if let name = resultVal?.string(forKey:  UserRecordDocumentKeys.name.rawValue), let image = resultVal?.blob(forKey:  UserRecordDocumentKeys.photo.rawValue)?.content {
                    let user = UserRecord.init(name: name, photo: image, extended: nil)
                    results.append(user)
                }
                
                num = num + 1
               
            }
            
          
        }
        catch {
            print("Error in query execution \(error)")
            return (nil,false)
        }
        return (results,true)
    }
    
   
   
}


// MARK: Prebuilt  Database
extension DatabaseManager {
    // TODO : Remove prebuilt database usage
    // tag::openPrebuiltDatabase[]
    func openPrebuiltDatabase(handler:(_ error:Error?)->Void) {
        // end::openPrebuiltDatabase[]
        do {
            // tag::prebuiltdbconfig[]
            var options = DatabaseConfiguration()
            guard let universityFolderUrl = _applicationSupportDirectory else {
                fatalError("Could not open Application Support Directory for app!")
                return
            }
            let dbFolderPath = universityFolderUrl.path
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: dbFolderPath) {
                try fileManager.createDirectory(atPath: dbFolderPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                
            }
            // Set the folder path for the CBLite DB
            options.directory = dbFolderPath
        
            // end::prebuiltdbconfig[]
            
            // tag::prebuiltdbopen[]
            // Load the prebuilt "universities" database if it does not exist as the specified folder
            if Database.exists(withName: kPrebuiltDBName, inDirectory: dbFolderPath) == false {
                // Load prebuilt database from App Bundle and copy over to Applications support path
                if let prebuiltPath = Bundle.main.path(forResource: kPrebuiltDBName, ofType: "cblite2") {
                    print("Will copy Prebuilt DB to path \(dbFolderPath)")
                    
                    try Database.copy(fromPath: prebuiltPath, toDatabase: "\(kPrebuiltDBName)", withConfig: options)
                    // load documents
//                                    DispatchQueue.global().async {
//                                        self.loadDocumentsIntoDB({ (error) in
//                                            print ("LOaded documents into database with error:\(error)")
//                                        })
//                                    }
                }
                else {
                    // Get handle to DB  specified path
                    _db = try Database(name: kPrebuiltDBName, config: options)
                    
                    print("Will create new database at \(dbFolderPath)")
                        DispatchQueue.global().async {
                        self.loadDocumentsIntoDB({ (error) in
                            print ("LOaded documents into database with error:\(error)")
                        })
                    }
                    
                }
                // Get handle to DB  specified path
                _db = try Database(name: kPrebuiltDBName, config: options)
               
            }
            else
            {
                print("Will open existing DB to path \(dbFolderPath)")
                
                // Gets handle to existing DB at specified path
                _db = try Database(name: kPrebuiltDBName, config: options)
                // load documents
//                DispatchQueue.global().async {
//                    self.loadDocumentsIntoDB({ (error) in
//                        print ("LOaded documents into database with error:\(error)")
//                    })
//                }
                
            }
            self.registerForDatabaseChanges()
            
            handler(nil)
        }catch {
            
            lastError = error
            handler(lastError)
        }
    }
    
    func closePrebuiltDatabase() -> Bool {
        do {
            print(#function)
            // Get handle to DB  specified path
            if let db = self.db {

                self.deregisterForDatabaseChanges()
                try db.close()

                _db  = nil
            }
            
            return true
        }
        catch {
            return false
        }
    }
    

    fileprivate func registerForDatabaseChanges() {

        // Add database change listener
        dbChangeListenerToken = db?.addChangeListener({ [weak self](change) in
            guard let `self` = self else {
                return
            }
            for docId in change.documentIDs   {
                if let docString = docId as? String {
                    let doc = self._db?.document(withID: docString)
                    if doc == nil {
                        print("Document was deleted")
                    }
                    else {
                        print("Document was added/updated")
                    }
                }
            }
        })

    }
    
    // tag::deregisterForDatabaseChanges[]
    fileprivate func deregisterForDatabaseChanges() {

        // Add database change listener
        if let dbChangeListenerToken = self.dbChangeListenerToken {
            db?.removeChangeListener(withToken: dbChangeListenerToken)
        }
    }
}


// MARK: DOcuments Loading
extension DatabaseManager {

    func loadDocumentsIntoDB(_ handler:@escaping (_ error:Error?)->Void) {
        print(#function)
        guard let db = db else {
            print("Database not initialized")
            DispatchQueue.main.sync {
                handler(CustomError.DatabaseNotInitialized)
            }
          
            return
        }
        
        
        let utils = FileUtils.init()
        let filesToLoad = utils.loadImageFilesFromFolder("faces")
         do {
            try db.inBatch {
                for (name,image) in filesToLoad {
                    let doc = MutableDocument.init()
                    doc.setBlob(Blob.init(contentType: "image/jpg", data: image.jpegData(compressionQuality: 1.0)!), forKey: "photo")
                
                    doc.setString(name, forKey: "name")
                    print ("name = \(name)")
                    try db.saveDocument(doc)
  
                }
            }
        }
        catch {
            print(error)
            DispatchQueue.main.sync {
                handler(error)
            }
        }
        DispatchQueue.main.sync {
            self._docsLoaded = true
            handler(nil)
        }
    }
   
}

// MARK Utils
extension DatabaseManager {
    fileprivate func enableCrazyLevelLogging() {
        //  Database.setLogLevel(.debug, domain: .all)
    }
}

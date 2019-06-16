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
    fileprivate let kPrebuiltDBName:String = "items"
    fileprivate let kPrebuiltDBFolder:String = "prebuilt"
    fileprivate var _db:Database?
    fileprivate var _docsLoaded:Bool = false
    
    fileprivate var _applicationDocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    fileprivate var _applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
    
    // predictions
    fileprivate var coreMLPredictiveModel = {
        return CoreMLPredictiveModel(mlModel: ItemClassifierCoreMLPredictiveModel.SharedInstance.model)
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
            self.deregisterPredictionModel()
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
        // add transformation function
        
        // This input transformation is not really required. This is just for testing purposes- I forced the
        // input to be different than what is expected 
        coreMLPredictiveModel.inputTransformer = { (input) in
            let val = input.value(forKey: input.keys[0])
             let transformed = [ItemClassifierCoreMLPredictiveModel.SharedInstance.inputFeatureNames[0]:val]
            return MutableDictionaryObject(data: transformed)
            
        }
        coreMLPredictiveModel.outputTransformer = { (output) in
            guard let result = output else {
                return nil
            }
            
            let label = result.string(forKey: kPredictionCategory)!
            let prob = result.dictionary(forKey: kPredictionProbability)?.value(forKey: label)
            
            let modifiedResult = [ kPredictionCategory: label, kPredictionProbability: prob]
            return MutableDictionaryObject(data: modifiedResult)
        
        }
        
        Database.prediction.registerModel(coreMLPredictiveModel, withName: ItemClassifierCoreMLPredictiveModel.name)
    }
    
    func deregisterPredictionModel() {
        print(#function)
        Database.prediction.unregisterModel(withName: ItemClassifierCoreMLPredictiveModel.name)
    }
    
    func createPredictiveIndexOnProperties(_ properties:[String])->Bool  {
        print(#function)

    // For searches on type property
        guard let db = db else {
            print ("Database is not initialized")
            return false
        }
        let model = ItemClassifierCoreMLPredictiveModel.name
        guard let propName = properties.first else {
            return false
        }
      
        let inputFeatureName = ItemClassifierCoreMLPredictiveModel.SharedInstance.inputFeatureNames[0]
        let input = Expression.value([propName: Expression.property(propName)])
        
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

// MARK: Item Classification
extension DatabaseManager {
    func useRegisteredModelToFindMatchingItemsInDBToInputImage(_ imageData:Data, imageName:String, propertyName:String)->(userRecords:[UserRecord]?,status:Bool) {
            print(#function)
            guard let db = db else {
                fatalError("Database not initialized")
                return (nil,false)
            }
    
            let modelName = ItemClassifierCoreMLPredictiveModel.name
            let inputFeatureName = ItemClassifierCoreMLPredictiveModel.SharedInstance.inputFeatureNames[0]
        
            // DO prediction on input param
            let inputPhotoParam = Expression.dictionary([propertyName : Expression.parameter(imageName)])
            let inputImagePrediction = Function.prediction(model: modelName, input: inputPhotoParam)
        
            let categoryKeyPath = ItemClassifierCoreMLPredictiveModel.outFeatureNames.kPredictionCategory.rawValue
            let probabilityKeyPath = ItemClassifierCoreMLPredictiveModel.outFeatureNames.kPredictionProbability.rawValue
        
        
            // Find matching category as long as the match has a probability of > 0.7
    
               let query = QueryBuilder
                .select(SelectResult.all(),SelectResult.expression(inputImagePrediction).as("PredictionResult"))
                .from(DataSource.database(db))
                .where(inputImagePrediction.property(categoryKeyPath)
                            .equalTo(Expression.property(UserRecordDocumentKeys.tag.rawValue))
                        .and(inputImagePrediction.property(probabilityKeyPath))
                            .greaterThanOrEqualTo(Expression.double(0.7)))
       
            // Set input parameters for query
            let params = Parameters()
        params.setBlob(Blob.init(contentType: "image/jpg", data: imageData), forName: imageName)
            query.parameters = params
    
            // Execute query
          //  print(try? query.explain())
            var results:[UserRecord] = [UserRecord]()
    
            do {
                //   print ("results are ...")
                for result in try query.execute() {
                     //  print("Distance  is :\(result.toDictionary())")
                    let resultVal = result.dictionary(forKey: "items")
                    print(result.toDictionary())
                    let matchDetails = result.dictionary(forKey: "PredictionResult")
                    let matchProbability = matchDetails?.value(forKey: probabilityKeyPath)
                    //print("Found \(resultVal?.count) matches")
                    if let name = resultVal?.string(forKey:  UserRecordDocumentKeys.tag.rawValue), let image = resultVal?.blob(forKey:  UserRecordDocumentKeys.photo.rawValue)?.content {
                        let tagAndMatch = "\(name) : \(matchProbability!)"
                        let user = UserRecord.init(tag: tagAndMatch, photo: image, extended: nil)
                        // print("\(name):user")
                        results.append(user)
                    }
                }
    
            }
            catch {
                print("Error in query execution \(error)")
                return (nil,false)
            }
            return (results,true)
    }
    
    ////////////// This API is currently not in use in app //////////////////////////////////////
    func addItemToDBWithPredictionResult(_ imageData:Data, imageName:String, propertyName:String)->Bool {
        print(#function)
        guard let db = db else {
            fatalError("Database not initialized")
            return false
        }
        guard let image = UIImage.init(data: imageData) else {
            fatalError("No image provided!")
            return false
        }
        
        
        do {
            
            let i = Int.random(in: 0 ..< 10000)
            
            let doc = MutableDocument.init(id: "\(imageName)_\(i)")
            doc.setBlob(Blob.init(contentType: "image/jpg", data: image.jpegData(compressionQuality: 1.0)!), forKey: "photo")
            /* NOTE :
             If data model did not store tags, you can create predictive index to cache the prediction results and use that in subsequent queries tags
             
             */
          
            // Classify directly using coreML model
            if let result = ItemClassifierService.init().runItemClassifierModelOnImage(image) {
            
                if let val = result.first?.value, val > 0.7 {
                    // Store the prediction results in the document so it can get synced up
                    doc.setString(result.first?.key, forKey: UserRecordDocumentKeys.tag.rawValue)
                    // we are saving the document with generated tag
                    // ALternatively, if the data model did not include a tag, we can just create doc and
                    // use predictive index to cache
                    try db.saveDocument(doc)
                }
                else {
                    print ("No matching category identified with probability > 0.7")
                    return false
                }
                
            }
            else {
                print ("Failed to classify input image")
                return false
            }
            


            
        }
        catch {
            print("Error in query execution \(error)")
            return false
            
        }
        return true
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
        let filesToLoad = utils.loadImageFilesFromFolder("items")
         do {
            try db.inBatch {
                var i = 0
                var fileCount  = 0
                for (name,images) in filesToLoad {
                    i = 0
                    fileCount = fileCount + images.count
                    for image in images {
                        let doc = MutableDocument.init(id: "\(name)_\(i)")
                        i = i + 1
                        doc.setBlob(Blob.init(contentType: "image/jpg", data: image.jpegData(compressionQuality: 1.0)!), forKey: "photo")
                        
                        doc.setString(name, forKey: UserRecordDocumentKeys.tag.rawValue)
                        print ("tag = \(name)")
                        try db.saveDocument(doc)
                    }
  
                }
                print("Number of images  is \(fileCount)")
                
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

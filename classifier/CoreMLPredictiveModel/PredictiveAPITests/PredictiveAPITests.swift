//
//  PredictiveAPITests.swift
//  PredictiveAPITests
//
//  Created by Priya Rajagopal on 1/10/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import XCTest


@testable import PredictiveAPI

class PredictiveAPITests: XCTestCase {
    var itemsClassifierService:ItemClassifierService = ItemClassifierService.init()
    var images:[String:[UIImage]] = [String:[UIImage]]()
    var testImage:Data!
    let dbMgr = DatabaseManager.shared
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        itemsClassifierService = ItemClassifierService()
        testImage = self.loadTestImage()
//        let utils = FileUtils.init()
//        images = utils.loadImageFilesFromFolder("items")
//         
        self.dbMgr.registerPredictionModel()
        

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        images.removeAll()
        self.dbMgr.closePrebuiltDatabase()
        self.dbMgr.deregisterPredictionModel()
    
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceOpenFacePrediction() {
        
        // 1. Convert input images into [OpenFaceInput]
        // measure only cost of prediction
        self.measure {
            for (name,image) in images {
          //     let _ = try? itemsClassifierService.runItemClassifierModelOnImage(image)
                }
            }
    }
    
  
}

// CBL Predictive APIs tests
extension PredictiveAPITests {
    // Write tests to open DB . Update details in DB
    
    func testMeasureBuildPredictionIndex() {
        self.measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
            dbMgr.openPrebuiltDatabase(handler: { (err) in
                startMeasuring()
                self.dbMgr.createPredictiveIndexOnProperties(["photo"])
                stopMeasuring()
                
            })
        }
    }
    
    func testMeasureDistanceLookup() {
            dbMgr.openPrebuiltDatabase(handler: { (err) in
                self.dbMgr.createPredictiveIndexOnProperties(["photo"])
                self.measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
                    
                    startMeasuring()
                    let results = self.dbMgr.useRegisteredModelToFindMatchingItemsInDBToInputImage(self.testImage, imageName: "test", propertyName: "photo")
                    print(results)
                    stopMeasuring()
                
                }
     
            })
        }
    
    func testMeasureImageLookupNoIndex() {
        dbMgr.openPrebuiltDatabase(handler: { (err) in
          
            self.measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
                
                startMeasuring()
                let results = self.dbMgr.useRegisteredModelToFindMatchingItemsInDBToInputImage(self.testImage, imageName:"test", propertyName: "photo")
                print(results)
                stopMeasuring()
                
            }
            
        })
    }

    func testMeasureImageLookupWithIndex() {
        dbMgr.openPrebuiltDatabase(handler: { (err) in
            self.dbMgr.createPredictiveIndexOnProperties(["photo"])
            self.measureMetrics([XCTPerformanceMetric.wallClockTime], automaticallyStartMeasuring: false) {
                
                startMeasuring()
                let results = self.dbMgr.useRegisteredModelToFindMatchingItemsInDBToInputImage(self.testImage, imageName:"test", propertyName: "photo")
                print(results)
                stopMeasuring()
                
            }
            
        })
    }
}

extension PredictiveAPITests {
    
    func loadTestImage()->Data {
        let bundle = Bundle(for: type(of: self))
        
        guard var image = UIImage.init(named: "headphone.jpg", in: bundle, compatibleWith: nil)
            else {
                return Data.init()
        }
        let utils = FileUtils.init()
        let imageData = image.jpegData(compressionQuality: 1.0)

        return imageData!
    }
}


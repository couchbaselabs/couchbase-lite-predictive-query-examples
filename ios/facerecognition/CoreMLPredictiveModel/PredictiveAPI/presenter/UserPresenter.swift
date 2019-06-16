//
//  UserPresenter.swift
//  PredictiveAPI
//
//  Created by Priya Rajagopal on 1/11/19.
//  Copyright © 2019 Couchbase Inc. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift


// MARK : typealias
enum UserRecordDocumentKeys:String {
    case type
    case name
    case photo
}


// MARK: UserPresenterProtocol
// To be implemented by presenter
protocol UserPresenterProtocol : PresenterProtocol {
     func lookupClosestMatchingRecord( _ record:UserRecord?)->Bool
}

// MARK: UserPresentingViewProtocol
// To be implemented by the presenting view
protocol UserPresentingViewProtocol:PresentingViewProtocol {
    func updateUIWithMatchingRecords(_ records:[UserRecord]?,error:Error?)
}

// MARK: UserPresenter
class UserPresenter:UserPresenterProtocol {
 
    fileprivate var dbMgr:DatabaseManager = DatabaseManager.shared
    // tag::userQueryToken[]
    fileprivate var userQueryToken:ListenerToken?
    // end::userQueryToken[]
    fileprivate var userQuery:Query?
    // end::userProfileDocId[]
    weak var associatedView: UserPresentingViewProtocol?
    
    deinit {
        if let userQueryToken = userQueryToken {
            userQuery?.removeChangeListener(withToken: userQueryToken)
        }
        userQuery = nil
    }
}



extension UserPresenter {
    func lookupClosestMatchingRecord( _ record:UserRecord?)->Bool {
        guard let db = dbMgr.db else {
            fatalError("db is not initialized at this point!")
        }
        guard let imageData = record?.photo , let name = record?.name else {
            print("Invalid input parameters")
            return false
        }
        
        DispatchQueue.global().async {
            let results = self.dbMgr.useRegisteredModelToFindClosestMatchesInDBToInputImage(imageData, imageName: name, propertyName: UserRecordDocumentKeys.photo.rawValue)
            
            print (results.userRecords)
            DispatchQueue.main.async {
                self.associatedView?.updateUIWithMatchingRecords(results.userRecords, error: nil)

            }
      
        }
        
        return true
    }
   
    
}


// MARK: PresenterProtocol
extension UserPresenter:PresenterProtocol {
    func attachPresentingView(_ view:PresentingViewProtocol) {
        self.associatedView = view as? UserPresentingViewProtocol
        
    }
    func detachPresentingView(_ view:PresentingViewProtocol) {
        self.associatedView = nil
    }
}

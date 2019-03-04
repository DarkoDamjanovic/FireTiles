//
//  FirestoreService.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 03.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation

import Firebase
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func testDb()
}

class FirestoreService {
    // swiftlint:disable:next identifier_name
    private let db: Firestore
    private let log = Logger()
    
    init(config: FirebaseConfig) {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        
        db = Firestore.firestore()
        db.settings = settings
    }
}

extension FirestoreService: FirestoreServiceProtocol {
    func testDb() {
        var iPhoneAd = [String: Any]()
        iPhoneAd["productId"] = "iPhoneXS"
        iPhoneAd["description"] = "Brand new, mostly unused, including warranty! 😃"
        iPhoneAd["addedServerTimestamp"] = FieldValue.serverTimestamp()
        
        var ref: DocumentReference?
        ref = db.collection("iPhoneAds").addDocument(data: iPhoneAd) { [weak self] error in
            if let error = error {
                self?.log.error(error)
            } else {
                self?.log.info("Document added with id: \(String(describing: ref?.documentID))")
            }
        }
    }
    
    func generateTestData() {
        for _ in 1...500 {
            var document = [String: Any]()
            document["location"] = GeoPoint(latitude: 0, longitude: 0)
        }
    }
}

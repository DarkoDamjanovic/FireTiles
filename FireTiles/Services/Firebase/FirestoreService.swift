//
//  FirestoreService.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 03.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import CoreLocation

import Firebase
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func generateTestDataOnce()
    func downloadTestDataOnce(completion: @escaping ([Place]) -> ())
}

class FirestoreService {
    // swiftlint:disable:next identifier_name
    private let db: Firestore
    private let log = Logger()
    private let userDefaults: UserDefaults
    
    init(config: FirebaseConfig,
         userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        
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
    
    func generateTestDataOnce() {
        guard userDefaults.bool(forKey: "testdata_already_written") == false else { return }
        userDefaults.set(true, forKey: "testdata_already_written")
        
        let ref = db.collection("Restaurants")
        for _ in 1...100 {
            let latRandom = Double.random(in: 37.65460531...37.78211206)
            let longRandom = Double.random(in: (-122.49137878)...(-122.39833832))
            
            var document = [String: Any]()
            document["location"] = GeoPoint(latitude: latRandom, longitude: longRandom)
            ref.addDocument(data: document)
        }
    }
    
    func downloadTestDataOnce(completion: @escaping ([Place]) -> ()) {
        db.collection("Restaurants").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                self?.log.error("Error getting documents: \(error)")
            } else {
                var places = [Place]()
                for document in snapshot!.documents {
                    self?.log.info("\(document.documentID) => \(document.data())")
                    
                    let placeDocument = document.data()
                    if let geoPoint = placeDocument["location"] as? GeoPoint {
                        let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        let place = Place(documentId: document.documentID, coordinate: location)
                        places.append(place)
                    }
                }
                completion(places)
            }
        }
    }
}

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
    func generateRandomPlaces(count: Int, completion: @escaping () -> ())
    func loadAllPlaces(completion: @escaping ([Place]) -> ())
    func getPlacesNearBy(coordinate: CLLocationCoordinate2D, completion: @escaping ([Place]) -> ())
}

class FirestoreService {
    private let db: Firestore
    private let log = Logger()
    private let userDefaults: UserDefaults
    
    private let tileLocationsField = "tileLocations"
    private let locationField = "location"
    private let collectionName = "Restaurants"
    
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
    func generateRandomPlaces(count: Int, completion: @escaping () -> ()) {
        guard count > 1 else { return }
        
        let ref = db.collection(collectionName)
        let dispatchGroup = DispatchGroup()
        var dbError: Error?
        for _ in 1...count {
            
            // San Francisco area
            let latRandom = Double.random(in: 37.65460531...37.78211206)
            let longRandom = Double.random(in: (-122.49137878)...(-122.39833832))
            
            let fireTiles = FireTile(precision: .p0_01).createSearchRegion(
                coordinate: CLLocationCoordinate2D(
                    latitude: latRandom,
                    longitude: longRandom
                )
            )
            
            var document = [String: Any]()
            document[locationField] = GeoPoint(latitude: latRandom, longitude: longRandom)
            document[tileLocationsField] = fireTiles
            
            dispatchGroup.enter()
            ref.addDocument(data: document) { error in
                if let error = error {
                    dbError = error
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let dbError = dbError {
                self.log.error(dbError)
            } else {
                completion()
            }
        }
    }
    
    func loadAllPlaces(completion: @escaping ([Place]) -> ()) {
        db.collection(collectionName).getDocuments { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                self?.log.error("Error getting documents: \(error)")
            } else {
                var places = [Place]()
                for document in snapshot!.documents {
                    self?.log.info("\(document.documentID) => \(document.data())")
                    
                    let placeDocument = document.data()
                    if let geoPoint = placeDocument[strongSelf.locationField] as? GeoPoint {
                        let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        let place = Place(documentId: document.documentID, coordinate: location)
                        places.append(place)
                    }
                }
                completion(places)
            }
        }
    }
    
    func getPlacesNearBy(coordinate: CLLocationCoordinate2D, completion: @escaping ([Place]) -> ()) {
        let centerLocation = FireTile(precision: .p0_01).location(coordinate: coordinate)
        
        db.collection(collectionName)
            .whereField(tileLocationsField, arrayContains: centerLocation)
            .getDocuments { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                self?.log.error("Error getting documents: \(error)")
            } else {
                var places = [Place]()
                for document in snapshot!.documents {
                    self?.log.info("\(document.documentID) => \(document.data())")
                    
                    let placeDocument = document.data()
                    if let geoPoint = placeDocument[strongSelf.locationField] as? GeoPoint {
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

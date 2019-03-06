//
//  FirestoreService.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 03.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

import Firebase
import FirebaseFirestore

protocol FirestoreServiceProtocol {
    func loadAllPlaces(completion: @escaping ([Place]) -> ())
    func getPlacesNearBy(coordinate: CLLocationCoordinate2D, precision: FireTile.TilePrecision, completion: @escaping ([Place]) -> ())
    func generateRandomPlaces(count: Int,
                              neCoord: CLLocationCoordinate2D,
                              swCoord: CLLocationCoordinate2D,
                              completion: @escaping () -> ())
}

class FirestoreService {
    private let db: Firestore
    private let log = Logger()
    private let userDefaults: UserDefaults
    
    private let tileLocationsField = "tileLocations"
    private let locationField = "location"
    private let collectionName = "Places"
    
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
    func generateRandomPlaces(count: Int,
                              neCoord: CLLocationCoordinate2D,
                              swCoord: CLLocationCoordinate2D,
                              completion: @escaping () -> ()) {
        guard count > 1 else { return }
        
        let ref = db.collection(collectionName)
        let dispatchGroup = DispatchGroup()
        var dbError: Error?
        
        for i in 1...count {
            self.log.info("Iteration: \(i)")
            let latRandom = Double.random(in: min(swCoord.latitude, neCoord.latitude)...max(swCoord.latitude, neCoord.latitude))
            let longRandom = Double.random(in: min(swCoord.longitude, neCoord.longitude)...max(swCoord.longitude, neCoord.longitude))
            
            var allTiles = [String]()
            
            let fireTiles0_01 = FireTile(precision: .p0_01).createSearchRegion(
                latitude: latRandom,
                longitude: longRandom
            )
            
            let fireTiles0_10 = FireTile(precision: .p0_10).createSearchRegion(
                latitude: latRandom,
                longitude: longRandom
            )
            
            let fireTiles1_00 = FireTile(precision: .p1_00).createSearchRegion(
                latitude: latRandom,
                longitude: longRandom
            )
            
            allTiles.append(contentsOf: fireTiles0_01)
            allTiles.append(contentsOf: fireTiles0_10)
            allTiles.append(contentsOf: fireTiles1_00)
            
            var document = [String: Any]()
            document[locationField] = GeoPoint(latitude: latRandom, longitude: longRandom)
            document[tileLocationsField] = allTiles
            
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
    
    func getPlacesNearBy(coordinate: CLLocationCoordinate2D, precision: FireTile.TilePrecision, completion: @escaping ([Place]) -> ()) {
        let centerLocation = FireTile(precision: precision).location(coordinate: coordinate)
        
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

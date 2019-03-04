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
        
        let batch = db.batch()
        for _ in 1...count {
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
            
            var data = [String: Any]()
            data[locationField] = GeoPoint(latitude: latRandom, longitude: longRandom)
            data[tileLocationsField] = allTiles
            
            let document = db.collection(self.collectionName).document()
            batch.setData(data, forDocument: document)
        }
        
        batch.commit() { err in
            if let err = err {
                self.log.error("Error writing batch \(err)")
            } else {
                self.log.info("Added \(count) new documents")
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
                    let placeDocument = document.data()
                    if let geoPoint = placeDocument[strongSelf.locationField] as? GeoPoint {
                        let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        let place = Place(documentId: document.documentID, coordinate: location)
                        places.append(place)
                    }
                }
                self?.log.info("Loaded \(snapshot!.documents.count) documents")
                completion(places)
            }
        }
    }
    
    func getPlacesNearBy(coordinate: CLLocationCoordinate2D, precision: FireTile.TilePrecision, completion: @escaping ([Place]) -> ()) {
        let locationTile = FireTile(precision: precision).location(coordinate: coordinate)
        
        db.collection(collectionName)
            .whereField(tileLocationsField, arrayContains: locationTile)
            .getDocuments { [weak self] (snapshot, error) in
            guard let strongSelf = self else { return }
            
            if let error = error {
                self?.log.error("Error getting documents: \(error)")
            } else {
                var places = [Place]()
                for document in snapshot!.documents {
                    let placeDocument = document.data()
                    if let geoPoint = placeDocument[strongSelf.locationField] as? GeoPoint {
                        let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        let place = Place(documentId: document.documentID, coordinate: location)
                        places.append(place)
                    }
                }
                self?.log.info("Loaded \(snapshot!.documents.count) documents nearby")
                completion(places)
            }
        }
    }
}

//
//  MapPresenter.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol MapPresenterProtocol {
    func viewDidLoad()
    func nearByTappedAt(coordindate: CLLocationCoordinate2D)
    func generateRandomPlaces(count: Int, neCoord: CLLocationCoordinate2D, swCoord: CLLocationCoordinate2D)
    func setPrecision(precision: FireTile.TilePrecision)
}

class MapPresenter {
    private let log = Logger()
    private unowned let view: MapViewControllerProtocol
    private let navigator: MapNavigatorProtocol
    private let firestoreService: FirestoreServiceProtocol
    
    /// Las Vegas
    private static let initialLatitude = 36.137781
    private static let initialLongitude = -115.148312
    
    private let initialLocation = CLLocationCoordinate2D(latitude: initialLatitude, longitude: initialLongitude)
    private let initialDistance = CLLocationDistance(exactly: 15000)!
    private var places = Set<Place>()
    private var nearByPlaces = Set<Place>()
    private var precision: FireTile.TilePrecision = .p0_01
    
    init(view: MapViewControllerProtocol,
         navigator: MapNavigatorProtocol,
         firestoreService: FirestoreServiceProtocol) {
        self.view = view
        self.navigator = navigator
        self.firestoreService = firestoreService
    }
    
    private func loadAllPlaces(_ places: [Place]) {
        self.places = Set<Place>(places)
        self.view.removeAnnotations()
        self.view.drawAnnotations(places: self.places)
    }
    
    deinit {
        log.info("")
    }
}

extension MapPresenter: MapPresenterProtocol {
    func viewDidLoad() {
        self.view.centerMapOnLocation(location: self.initialLocation, distance: self.initialDistance)
        self.firestoreService.loadAllPlaces { [weak self] places in
            self?.loadAllPlaces(places)
        }
    }
    
    func nearByTappedAt(coordindate: CLLocationCoordinate2D) {
        self.firestoreService.getPlacesNearBy(coordinate: coordindate, precision: self.precision) { [weak self] places in
            guard let strongSelf = self else { return }
            strongSelf.nearByPlaces = Set<Place>(places)
            strongSelf.view.removeAnnotations()
            let notNearByPlaces = strongSelf.places.subtracting(strongSelf.nearByPlaces)
            strongSelf.view.drawAnnotations(places: notNearByPlaces)
            strongSelf.view.drawNearByAnnotations(places: strongSelf.nearByPlaces)
        }
    }
    
    func generateRandomPlaces(count: Int, neCoord: CLLocationCoordinate2D, swCoord: CLLocationCoordinate2D) {
        self.view.activityIndicatorState(enabled: true)
        self.firestoreService.generateRandomPlaces(count: count,
                                                   neCoord: neCoord,
                                                   swCoord: swCoord) {
            self.firestoreService.loadAllPlaces(completion: { [weak self] places in
                self?.loadAllPlaces(places)
                self?.view.activityIndicatorState(enabled: false)
            })
        }
    }
    
    func setPrecision(precision: FireTile.TilePrecision) {
        self.precision = precision
    }
}

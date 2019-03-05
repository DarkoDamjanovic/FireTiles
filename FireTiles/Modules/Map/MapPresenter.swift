//
//  MapPresenter.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapPresenterProtocol {
    func viewDidLoad()
    func buttonNearByTapped()
    func buttonNewPlacesTapped()
}

class MapPresenter {
    private let log = Logger()
    private unowned let view: MapViewControllerProtocol
    private let navigator: MapNavigatorProtocol
    private let firestoreService: FirestoreServiceProtocol
    
    private let initialLocation = CLLocationCoordinate2D(latitude: 37.74520008, longitude: -122.4464035)
    private let initialDistance = CLLocationDistance(exactly: 15000)!
    private var places = Set<Place>()
    private var nearByPlaces = Set<Place>()
    
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
    
    func buttonNearByTapped() {
        self.firestoreService.getPlacesNearBy(coordinate: self.initialLocation) { [weak self] places in
            guard let strongSelf = self else { return }
            strongSelf.nearByPlaces = Set<Place>(places)
            strongSelf.view.removeAnnotations()
            let notNearByPlaces = strongSelf.places.subtracting(strongSelf.nearByPlaces)
            strongSelf.view.drawAnnotations(places: notNearByPlaces)
            strongSelf.view.drawNearByAnnotations(places: strongSelf.nearByPlaces)
        }
    }
    
    func buttonNewPlacesTapped() {
        self.view.activityIndicatorState(enabled: true)
        self.firestoreService.generateRandomPlaces(count: 100) {
            self.firestoreService.loadAllPlaces(completion: { [weak self] places in
                self?.loadAllPlaces(places)
                self?.view.activityIndicatorState(enabled: false)
            })
        }
    }
}

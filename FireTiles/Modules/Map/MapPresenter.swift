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
    var places: [Place] { get }
    
    func viewDidLoad()
}

class MapPresenter {
    private let log = Logger()
    private unowned let view: MapViewControllerProtocol
    private let navigator: MapNavigatorProtocol
    private let firestoreService: FirestoreServiceProtocol
    
    private let initialLocation = CLLocation(latitude: 37.74520008, longitude: -122.4464035)
    private let initialDistance = CLLocationDistance(exactly: 15000)!
    private(set) var places = [Place]()
    
    init(view: MapViewControllerProtocol,
         navigator: MapNavigatorProtocol,
         firestoreService: FirestoreServiceProtocol) {
        self.view = view
        self.navigator = navigator
        self.firestoreService = firestoreService
    }
    
    deinit {
        log.info("")
    }
}

extension MapPresenter: MapPresenterProtocol {
    func viewDidLoad() {
        self.view.centerMapOnLocation(location: self.initialLocation, distance: self.initialDistance)
        self.firestoreService.generateTestDataOnce()
        self.firestoreService.downloadTestDataOnce { [weak self] places in
            guard let strongSelf = self else { return }
            strongSelf.places = places
            strongSelf.view.drawAnnotations(places: strongSelf.places)
        }
    }
}

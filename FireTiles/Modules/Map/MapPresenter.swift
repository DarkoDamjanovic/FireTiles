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
}

class MapPresenter {
    private let log = Logger()
    private unowned let view: MapViewControllerProtocol
    private let navigator: MapNavigatorProtocol
    private let firestoreService: FirestoreServiceProtocol
    
    private let initialLocation = CLLocation(latitude: 37.74520008, longitude: -122.4464035)
    private let initialDistance = CLLocationDistance(exactly: 15000)!
    
    private var locations = [CLLocation]()
    
    init(view: MapViewControllerProtocol,
         navigator: MapNavigatorProtocol,
         firestoreService: FirestoreServiceProtocol) {
        self.view = view
        self.navigator = navigator
        self.firestoreService = firestoreService
    }
    
    private func drawAnnotations() {
        
    }
    
    deinit {
        log.info("")
    }
}

extension MapPresenter: MapPresenterProtocol {
    func viewDidLoad() {
        self.view.centerMapOnLocation(location: self.initialLocation, distance: self.initialDistance)
        self.firestoreService.generateTestDataOnce()
        self.firestoreService.downloadTestDataOnce { [weak self] locations in
            self?.locations = locations
        }
    }
}

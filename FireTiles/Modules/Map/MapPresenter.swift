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
    
    private let initialLocation = CLLocation(latitude: 40.0, longitude: -100.0)
    private let initialDistance = CLLocationDistance(exactly: 1000000)!
    
    init(view: MapViewControllerProtocol,
         navigator: MapNavigatorProtocol) {
        self.view = view
        self.navigator = navigator
    }
    
    deinit {
        log.info("")
    }
}

extension MapPresenter: MapPresenterProtocol {
    func viewDidLoad() {
        self.view.centerMapOnLocation(location: self.initialLocation, distance: self.initialDistance)
    }
}

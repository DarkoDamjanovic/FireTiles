//
//  MapViewController.swift
//  Unfurbished
//
//  Created by Darko Damjanovic on 05.01.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol MapViewControllerProtocol: AnyObject {
    func centerMapOnLocation(location: CLLocation, distance: CLLocationDistance)
}

class MapViewController: UIViewController {
    private let log = Logger()
    @IBOutlet private weak var mapView: MKMapView!
    
    var presenter: MapPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.presenter.viewDidLoad()
    }
    
    private func setupUI() {
        
    }
    
    deinit {
        log.info("")
    }
}

extension MapViewController: MapViewControllerProtocol {
    func centerMapOnLocation(location: CLLocation, distance: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: distance,
            longitudinalMeters: distance
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

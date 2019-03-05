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
    func drawAnnotations(places: [Place])
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
        self.mapView.delegate = self
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
    
    func drawAnnotations(places: [Place]) {
        for place in places {
            let annotation = Annotation(
                documentId: place.documentId,
                coordinate: place.coordinate
            )
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "annotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = false
            pinView!.clusteringIdentifier = nil
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

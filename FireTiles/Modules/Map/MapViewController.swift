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
    func activityIndicatorState(enabled: Bool)
    func removeAnnotations()
    func drawAnnotations(places: Set<Place>)
    func drawNearByAnnotations(places: Set<Place>)
    func centerMapOnLocation(location: CLLocationCoordinate2D, distance: CLLocationDistance)
}

class MapViewController: UIViewController {
    private let log = Logger()
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var presenter: MapPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.presenter.viewDidLoad()
    }
    
    private func setupUI() {
        self.activityIndicator.isHidden = true
        self.mapView.delegate = self
    }
    
    @IBAction func buttonNearByTapped(_ sender: Any) {
        self.presenter.buttonNearByTapped()
    }
    
    @IBAction func buttonNewPlacesTapped(_ sender: Any) {
        self.presenter.buttonNewPlacesTapped()
    }
    
    deinit {
        log.info("")
    }
}

extension MapViewController: MapViewControllerProtocol {
    func centerMapOnLocation(location: CLLocationCoordinate2D, distance: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(
            center: location,
            latitudinalMeters: distance,
            longitudinalMeters: distance
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removeAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func drawAnnotations(places: Set<Place>) {
        let annotations = places.map { Annotation(documentId: $0.documentId, coordinate: $0.coordinate) }
        self.mapView.addAnnotations(annotations)
        for place in places {
            let annotation = Annotation(
                documentId: place.documentId,
                coordinate: place.coordinate
            )
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func drawNearByAnnotations(places: Set<Place>) {
        let annotations = places.map { Annotation(documentId: $0.documentId, coordinate: $0.coordinate, nearBy: true) }
        self.mapView.addAnnotations(annotations)
    }
    
    func activityIndicatorState(enabled: Bool) {
        if enabled {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        guard let myAnnotation = annotation as? Annotation else { return nil }
        
        let reuseId = "annotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: reuseId)
        } else {
            pinView!.annotation = myAnnotation
        }
        
        pinView!.canShowCallout = false
        pinView!.animatesDrop = false
        pinView!.clusteringIdentifier = nil
        pinView!.pinTintColor = myAnnotation.color
        
        return pinView
    }
}

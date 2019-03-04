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
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mapTapped(recognizer:)))
        self.mapView.addGestureRecognizer(singleTapGesture)
    }
    
    @objc private func mapTapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.mapView)
        let coordindate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
        if recognizer.numberOfTouches == 1 {
            self.presenter.nearByTappedAt(coordindate: coordindate)
        }
    }
    
    @IBAction func buttonLeftTapped(_ sender: Any) {
        let nePoint = CGPoint(x: self.mapView.bounds.maxX, y: self.mapView.bounds.origin.y)
        let swPoint = CGPoint(x: self.mapView.bounds.minX, y: self.mapView.bounds.maxY)
        let neCoord = self.mapView.convert(nePoint, toCoordinateFrom: self.mapView)
        let swCoord = self.mapView.convert(swPoint, toCoordinateFrom: self.mapView)
        
        let sheet = UIAlertController(title: "Add places", message: "Add random places in current visible map view region.", preferredStyle: .actionSheet)
        let random100Action = UIAlertAction(title: "Add random 10 places", style: .default) { alertAction in
            self.presenter.generateRandomPlaces(count: 10, neCoord: neCoord, swCoord: swCoord)
        }
        let random300Action = UIAlertAction(title: "Add random 30 places", style: .default) { alertAction in
            self.presenter.generateRandomPlaces(count: 30, neCoord: neCoord, swCoord: swCoord)
        }
        let random500Action = UIAlertAction(title: "Add random 50 places", style: .default) { alertAction in
            self.presenter.generateRandomPlaces(count: 50, neCoord: neCoord, swCoord: swCoord)
        }
        sheet.addAction(random100Action)
        sheet.addAction(random300Action)
        sheet.addAction(random500Action)
        self.present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func buttonRightTapped(_ sender: Any) {
        let sheet = UIAlertController(title: "Bounding box size", message: "Set the bounding box size for nearby places search. Tap on the map to search.", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "approx. region 2.5km x 3.3km", style: .default) { alertAction in
            self.presenter.setPrecision(precision: .p0_01)
        }
        let action2 = UIAlertAction(title: "approx. region 8.5km x 11km", style: .default) { alertAction in
            self.presenter.setPrecision(precision: .p0_10)
        }
        let action3 = UIAlertAction(title: "approx. region 85km x 111km", style: .default) { alertAction in
            self.presenter.setPrecision(precision: .p1_00)
        }
        sheet.addAction(action1)
        sheet.addAction(action2)
        sheet.addAction(action3)
        self.present(sheet, animated: true, completion: nil)
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

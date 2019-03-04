//
//  Annotation.swift
//  FireTiles
//
//  Created by Darko Damjanovic on 05.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    let title: String? = nil
    var subtitle: String? = nil
    var documentId: String
    let coordinate: CLLocationCoordinate2D
    private(set) var color = MKPinAnnotationView.redPinColor()
    
    init(documentId: String, coordinate: CLLocationCoordinate2D, nearBy: Bool = false) {
        self.documentId = documentId
        self.coordinate = coordinate
        if nearBy {
            self.color = MKPinAnnotationView.greenPinColor()
        }
        super.init()
    }
}

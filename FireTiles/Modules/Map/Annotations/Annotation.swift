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
    
    init(documentId: String, coordinate: CLLocationCoordinate2D) {
        self.documentId = documentId
        self.coordinate = coordinate
        super.init()
    }
}

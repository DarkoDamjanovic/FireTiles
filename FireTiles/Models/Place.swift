//
//  Place.swift
//  FireTiles
//
//  Created by Darko Damjanovic on 05.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import CoreLocation

struct Place {
    var documentId: String
    var coordinate: CLLocationCoordinate2D
}

extension Place: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(documentId)
    }
}

extension Place: Equatable {
    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.documentId == rhs.documentId
    }
}

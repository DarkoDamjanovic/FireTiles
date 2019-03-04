//
//  FireTile.swift
//  FireTiles
//
//  Created by Darko Damjanovic on 05.03.19.
//  Copyright © 2019 SolidRock. All rights reserved.
//

import Foundation
import CoreLocation

class FireTile {
    enum TilePrecision: String {
        /// precision 0.01 decimal degrees for latitude and longitude
        /// this roughly translates to a search region of 2.5km x 3.3km
        case p0_01
        
        /// precision 0.10 decimal degrees for latitude and longitude
        /// this roughly translates to a search region of 8.5km x 11km
        case p0_10
        
        /// precision 1.00 decimal degrees for latitude and longitude
        /// this roughly translates to a search region of 85km x 111km
        case p1_00
    }
    let tilePrecision: TilePrecision
    
    init(precision: TilePrecision) {
        self.tilePrecision = precision
    }
    
    func createSearchRegion(latitude: Double, longitude: Double) -> [String] {
        return self.createSearchRegion(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    }
    
    func createSearchRegion(coordinate: CLLocationCoordinate2D) -> [String] {
        var latitude = Decimal()
        var longitude = Decimal()
        var precision = Decimal()
        
        switch self.tilePrecision {
        case .p0_01:
            latitude = Decimal(Int(coordinate.latitude * 100)) / Decimal(100)
            longitude = Decimal(Int(coordinate.longitude * 100)) / Decimal(100)
            precision = Decimal(string: "0.01")!
            
        case .p0_10:
            latitude = Decimal(Int(coordinate.latitude * 10)) / Decimal(10)
            longitude = Decimal(Int(coordinate.longitude * 10)) / Decimal(10)
            precision = Decimal(string: "0.10")!
            
        case .p1_00:
            latitude = Decimal(Int(coordinate.latitude))
            longitude = Decimal(Int(coordinate.longitude))
            precision = Decimal(string: "1.00")!
        }
        return self.generateTiles(latitude: latitude, longitude: longitude, precision: precision)
    }
    
    private func generateTiles(latitude: Decimal, longitude: Decimal, precision: Decimal) -> [String] {
        var tiles = [String]()
        let northWestTile = "\(tilePrecision.rawValue):\(latitude - precision)/\(longitude - precision)"
        let northTile = "\(tilePrecision.rawValue):\(latitude - precision)/\(longitude)"
        let northEastTile = "\(tilePrecision.rawValue):\(latitude - precision)/\(longitude + precision)"
        
        let westTile = "\(tilePrecision.rawValue):\(latitude)/\(longitude - precision)"
        let centerTile = "\(tilePrecision.rawValue):\(latitude)/\(longitude)"
        let eastTile = "\(tilePrecision.rawValue):\(latitude)/\(longitude + precision)"
        
        let southWestTile = "\(tilePrecision.rawValue):\(latitude + precision)/\(longitude - precision)"
        let southTile = "\(tilePrecision.rawValue):\(latitude + precision)/\(longitude)"
        let southEastTile = "\(tilePrecision.rawValue):\(latitude + precision)/\(longitude + precision)"
        
        tiles.append(northWestTile)
        tiles.append(northTile)
        tiles.append(northEastTile)
        tiles.append(westTile)
        tiles.append(centerTile)
        tiles.append(eastTile)
        tiles.append(southWestTile)
        tiles.append(southTile)
        tiles.append(southEastTile)
        
        return tiles
    }
    
    func location(coordinate: CLLocationCoordinate2D) -> String {
        var latitude = Decimal()
        var longitude = Decimal()
        
        switch self.tilePrecision {
        case .p0_01:
            latitude = Decimal(Int(coordinate.latitude * 100)) / Decimal(100)
            longitude = Decimal(Int(coordinate.longitude * 100)) / Decimal(100)

        case .p0_10:
            latitude = Decimal(Int(coordinate.latitude * 10)) / Decimal(10)
            longitude = Decimal(Int(coordinate.longitude * 10)) / Decimal(10)
            
        case .p1_00:
            latitude = Decimal(Int(coordinate.latitude))
            longitude = Decimal(Int(coordinate.longitude))
        }
        
        return "\(tilePrecision.rawValue):\(latitude)/\(longitude)"
    }
}

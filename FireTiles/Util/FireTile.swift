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
        case p0_01
        case p0_02
        case p0_05
        case p0_1
    }
    let precision: TilePrecision
    
    init(precision: TilePrecision) {
        self.precision = precision
    }
    
    func createRegion(coordinate: CLLocationCoordinate2D) -> [String] {
        var tiles = [String]()
        
        switch self.precision {
        case .p0_01:
            let latitude = Decimal(Int(coordinate.latitude * 100)) / Decimal(100)
            let longitude = Decimal(Int(coordinate.longitude * 100)) / Decimal(100)
            let precision = Decimal(string: "0.01")!
            
            let northWestTile = "\(TilePrecision.p0_01.rawValue):\(latitude - precision)/\(longitude - precision)"
            let northTile = "\(TilePrecision.p0_01.rawValue):\(latitude - precision)/\(longitude)"
            let northEastTile = "\(TilePrecision.p0_01.rawValue):\(latitude - precision)/\(longitude + precision)"
            
            let westTile = "\(TilePrecision.p0_01.rawValue):\(latitude)/\(longitude - precision)"
            let centerTile = "\(TilePrecision.p0_01.rawValue):\(latitude)/\(longitude)"
            let eastTile = "\(TilePrecision.p0_01.rawValue):\(latitude)/\(longitude + precision)"
            
            let southWestTile = "\(TilePrecision.p0_01.rawValue):\(latitude + precision)/\(longitude - precision)"
            let southTile = "\(TilePrecision.p0_01.rawValue):\(latitude + precision)/\(longitude)"
            let southEastTile = "\(TilePrecision.p0_01.rawValue):\(latitude + precision)/\(longitude + precision)"
            
            tiles.append(northWestTile)
            tiles.append(northTile)
            tiles.append(northEastTile)
            tiles.append(westTile)
            tiles.append(centerTile)
            tiles.append(eastTile)
            tiles.append(southWestTile)
            tiles.append(southTile)
            tiles.append(southEastTile)
        default:
            break
        }

        return tiles
    }
    
    func location(coordinate: CLLocationCoordinate2D) -> String {
        var center = ""
        switch self.precision {
        case .p0_01:
            let latitude = Decimal(Int(coordinate.latitude * 100)) / Decimal(100)
            let longitude = Decimal(Int(coordinate.longitude * 100)) / Decimal(100)
            center = "\(TilePrecision.p0_01.rawValue):\(latitude)/\(longitude)"

        default:
            break
        }
        
        return center
    }
}


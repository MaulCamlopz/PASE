//
//  LocationSimulator.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation
import CoreLocation

/// Simple simulator that maps location name to coordinates.
/// This intentionally simulates "last known location".
struct LocationSimulator {
    static func coords(for locationName: String) -> CLLocationCoordinate2D {
        // deterministic pseudo-random but stable mapping via hashing
        let seed = abs(locationName.hashValue)
        let lat =  -30.0 + Double((seed % 1000)) * 0.06 // range approx -30..30
        let lon = -120.0 + Double(((seed / 1000) % 1000)) * 0.12 // range approx -120..0
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

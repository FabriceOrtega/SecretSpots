//
//  RequestedSpot.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 15/04/2021.
//

import Foundation

struct RequestedSpot: Decodable {
    
    let title: String?
    let subtitle: String?
    let lat: Double
    let long: Double
    let category: String

    
}

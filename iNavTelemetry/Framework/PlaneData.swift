//
//  PlaneData.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/25/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

struct PlaneData : Codable {
    var lat : Double
    var lng : Double
    var alt : Int
    var speed : Int
    var heading : Int
    var photo : String
}

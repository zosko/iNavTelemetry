//
//  PlaneData.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 10/25/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

enum PlaneType : Int, Codable {
    case airport = 0
    case plane = 1
}

struct PlaneData : Codable {
    var lat : Double
    var lng : Double
    var alt : Int
    var speed : Int
    var heading : Int
    var photo : String
    var name : String
    var type : PlaneType
}

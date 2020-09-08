//
//  LocationPointAnnotation.swift
//  iNavTelemetryOSX
//
//  Created by Bosko Petreski on 5/26/20.
//  Copyright © 2020 Bosko Petreski. All rights reserved.
//

#if os(OSX)
    import Cocoa
#else
    import UIKit
#endif
import MapKit

class LocationPointAnnotation: MKPointAnnotation {
    var imageName: String!
}

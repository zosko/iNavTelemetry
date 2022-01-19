//
//  SmartPortSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest
@testable import iNavTelemetry

class SmartPortSpec: XCTestCase {

    func testSmartPort() throws {
        let smartPort = SmartPort()
        XCTAssertFalse(smartPort.process_incoming_bytes(incomingData: Data()))
    }

}

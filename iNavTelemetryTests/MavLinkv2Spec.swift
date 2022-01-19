//
//  MavLinkv2Spec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest

import XCTest
@testable import iNavTelemetry

class MavLinkv2Spec: XCTestCase {

    func testMavLinkV2() throws {
        let mavLink = MavLink_v2()
        XCTAssertFalse(mavLink.process_incoming_bytes(incomingData: Data()))
    }

}

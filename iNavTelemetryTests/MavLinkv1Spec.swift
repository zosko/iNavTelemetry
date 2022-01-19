//
//  MavLinkv1Spec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest

@testable import iNavTelemetry

class MavLinkv1Spec: XCTestCase {

    func testMavLinkV1() throws {
        let mavLink = MavLink_v1()
        XCTAssertFalse(mavLink.process_incoming_bytes(incomingData: Data()))
    }

}

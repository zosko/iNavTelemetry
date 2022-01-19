//
//  MSPv2Spec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest
@testable import iNavTelemetry

class MSPv2Spec: XCTestCase {

    func testMSPV2() throws {
        let msp = MSP_V2()
        let bytes: [UInt8] = [36,88,60,0,101,0,101,0,231]
        XCTAssertEqual(msp.request(messageID: .MSP_STATUS), Data(bytes: bytes, count: 9))
        XCTAssertFalse(msp.process_incoming_bytes(incomingData: Data()))
    }

}

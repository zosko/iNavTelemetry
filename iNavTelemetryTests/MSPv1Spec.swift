//
//  MSPv1Spec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest
@testable import iNavTelemetry

class MSPv1Spec: XCTestCase {

    func testMSPV1() throws {
        let msp = MSP_V1()
        let bytes: [UInt8] = [36,77,60,0,101,101]
        XCTAssertEqual(msp.request(messageID: .MSP_STATUS), Data(bytes: bytes, count: 6))
        XCTAssertFalse(msp.process(Data()))
    }

}

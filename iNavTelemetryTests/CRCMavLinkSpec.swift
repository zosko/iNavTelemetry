//
//  CRCMavLinkSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 2.2.22.
//

import XCTest
@testable import iNavTelemetry

class CRCMavLinkSpec: XCTestCase {

    func testCRCMavLink() throws {
        let crc = CRCMAVLink()
        
        crc.start_checksum()
        crc.update_checksum(0)
        crc.finish_checksum(0)
        
        XCTAssertEqual(crc.getMSB(), 226)
        XCTAssertEqual(crc.getLSB(), 41)
    }


}

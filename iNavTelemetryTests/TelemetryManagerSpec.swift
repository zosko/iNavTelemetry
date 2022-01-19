//
//  TelemetryManagerSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 1/19/22.
//

import XCTest
@testable import iNavTelemetry

class TelemetryManagerSpec: XCTestCase {

    func testTelemetryManager() throws {
        let telemetryManager = TelemetryManager()
        let unknownTelemetry = InstrumentTelemetry(packet: Packet(), telemetryType: .unknown)
        
        XCTAssertEqual(telemetryManager.telemetry,unknownTelemetry)
        XCTAssertFalse(telemetryManager.parse(incomingData: Data()))
    }
}

extension InstrumentTelemetry: Equatable {}

public func ==(lhs: InstrumentTelemetry, rhs: InstrumentTelemetry) -> Bool {
    return lhs.location == rhs.location && lhs.telemetryType == rhs.telemetryType
}

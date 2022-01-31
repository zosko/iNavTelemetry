//
//  AppViewModelSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 31.1.22.
//

import XCTest
@testable import iNavTelemetry

class AppViewModelSpec: XCTestCase {

    func testViewModel() throws {
        let localStorage = [URL(string: "11")!,URL(string: "22")!,URL(string: "33")!]
        let cloudStorage = [URL(string: "11")!,URL(string: "22")!,URL(string: "44")!]
        let mergedStorage = localStorage + cloudStorage
        let sorted = mergedStorage.uniqued().sortFiles()
        
        XCTAssertEqual(sorted, [URL(string: "44")!,
                                URL(string: "33")!,
                                URL(string: "22")!,
                                URL(string: "11")!])
    }

}

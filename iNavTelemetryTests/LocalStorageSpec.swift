//
//  LocalStorageSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 25.1.22.
//

import XCTest
import Combine
@testable import iNavTelemetry

class DataLoggerManagerMock: DataLoggerProtocol {
    
    private(set) var sampleLogs: [URL] = []
    
    func save(data: String, name: String) -> URL? {
        sampleLogs.append(URL(string: "111")!)
        return URL(string: name)
    }
    
    func fetch() -> AnyPublisher<[URL], Never> {
        return Just(sampleLogs)
            .eraseToAnyPublisher()
    }
    
    func clean() {
        sampleLogs = []
    }
    
}

class LocalStorageSpec: XCTestCase {
    func testLocalStorage() throws {

        let log1 = LogTelemetry(id: "1", lat: 10.0, lng: 10.0)
        let log2 = LogTelemetry(id: "1", lat: 20.0, lng: 20.0)
        let log3 = LogTelemetry(id: "1", lat: 30.0, lng: 30.0)
        
        let loggerManager = DataLoggerManagerMock()
        let storage = LocalStorage(loggerManager: loggerManager)

        storage.fetch()
        
        XCTAssertEqual(storage.logs, [])
        
        storage.start()
        

        storage.save(packet: log1)
        
        storage.save(packet: log2)
        
        storage.save(packet: log3)
                
        XCTAssertNotNil(storage.stop())
        
        storage.fetch()
        
        XCTAssertEqual(storage.logs, [URL(string: "111")!])
        
        storage.clear()
        storage.fetch()
        
        XCTAssertEqual(storage.logs, [])
        
        XCTAssertTrue(LocalStorage.toName(timestamp: 0).contains("1970 Jan 1 "))
        
    }
}

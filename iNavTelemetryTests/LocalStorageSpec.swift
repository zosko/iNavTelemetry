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
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    func testLocalStorage() throws {

        var arrLogs: [URL] = []
        
        let log1 = LogTelemetry(id: "1", lat: 10.0, lng: 10.0)
        let log2 = LogTelemetry(id: "1", lat: 20.0, lng: 20.0)
        let log3 = LogTelemetry(id: "1", lat: 30.0, lng: 30.0)
        
        let loggerManager = DataLoggerManagerMock()
        let storage = LocalStorage(loggerManager: loggerManager)

        let expectation = self.expectation(description: "Fetch logs")
        storage.fetch().sink { logs in
            expectation.fulfill()
            arrLogs = logs
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(arrLogs, [])
        
        storage.start()
        

        storage.save(packet: log1)
        
        storage.save(packet: log2)
        
        storage.save(packet: log3)
                
        XCTAssertNotNil(storage.stop())
        
        let expectation1 = self.expectation(description: "Fetch logs")
        storage.fetch().sink { logs in
            expectation1.fulfill()
            arrLogs = logs
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(arrLogs, [URL(string: "111")!])
        
        storage.clear()
        
        let expectation2 = self.expectation(description: "Fetch logs")
        storage.fetch().sink { logs in
            expectation2.fulfill()
            arrLogs = logs
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(arrLogs, [])
        
        XCTAssertTrue(LocalStorage.toName(timestamp: 0).contains("1970 Jan 1 "))
        
    }
}

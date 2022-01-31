//
//  CloudStorageSpec.swift
//  iNavTelemetryTests
//
//  Created by Bosko Petreski on 24.1.22.
//

import XCTest
import Combine
@testable import iNavTelemetry

class CloudManagerMock: FileManagerProtocol {
    private(set) var sampleLogs: [URL] = []

    func create() {  }
    func save(file: URL) { sampleLogs.append(file) }
    func fetch() -> AnyPublisher<[URL],Never> {
        return Just(sampleLogs)
            .eraseToAnyPublisher()
    }
    func clear() { sampleLogs = [] }
}

class CloudStorageSpec: XCTestCase {
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func testCloudStorage() throws {
        var arrLogs: [URL] = []
        
        let fileA = URL(string: "111")!
        let fileB = URL(string: "222")!
        let fileC = URL(string: "333")!
        let fileD = URL(string: "444")!

        let cloudManagerMock = CloudManagerMock()

        let storage = CloudStorage(cloudProtocol: cloudManagerMock)

        let expectation = self.expectation(description: "Fetch logs")
        storage.fetch().sink { logs in
            expectation.fulfill()
            arrLogs = logs
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(arrLogs,[])
        
        storage.save(file: fileA)
        storage.save(file: fileD)
        storage.save(file: fileB)
        storage.save(file: fileC)
        
        let expectation1 = self.expectation(description: "Fetch logs")
        storage.fetch().sink { logs in
            expectation1.fulfill()
            arrLogs = logs
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(arrLogs,[fileD,fileC,fileB,fileA])
        storage.clear()
        
        let expectation2 = self.expectation(description: "Fetch logs")
        storage.fetch().sink { logs in
            expectation2.fulfill()
            arrLogs = logs
        }
        .store(in: &cancellables)
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(arrLogs, [])
    }
    
    func testFilterFile() throws {
        let fileA = URL(string: "111")!
        let fileB = URL(string: "222")!
        let fileC = URL(string: "3a3")!
        let fileD = URL(string: "bbb")!
        
        XCTAssertTrue(fileA.filterFile())
        XCTAssertTrue(fileB.filterFile())
        XCTAssertFalse(fileC.filterFile())
        XCTAssertFalse(fileD.filterFile())
        
    }
    
    func testSortFiles() throws {
        let fileA = URL(string: "111")!
        let fileB = URL(string: "222")!
        let fileC = URL(string: "444")!
        let fileD = URL(string: "333")!
        let fileE = URL(string: "100")!
        
        let array = [fileA,fileB,fileC,fileD,fileE]
        
        XCTAssertEqual(array.sortFiles(), [fileC,fileD,fileB,fileA,fileE])
        
    }
    
    func testSortFilesWithInvalidValues() throws {
        let fileA = URL(string: "111")!
        let fileB = URL(string: "222")!
        let fileX = URL(string: "99z")!
        let fileY = URL(string: "abc")!
        
        let array = [fileX,fileY,fileA,fileB,]
        
        XCTAssertEqual(array.sortFiles(), [fileX,fileY,fileB,fileA])
        
    }

}

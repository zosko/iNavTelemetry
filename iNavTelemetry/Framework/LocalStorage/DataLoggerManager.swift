//
//  DataLoggerManager.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 25.1.22.
//

import Foundation
import Combine

protocol DataLoggerProtocol {
    func save(data: String, name: String) -> URL?
    func fetch() -> AnyPublisher<[URL],Never>
    func clean()
}

final class DataLoggerManager: DataLoggerProtocol {
    
    private let fileManager: FileManager
    private var pathLog: URL? { fileManager.urls(for: .documentDirectory, in: .userDomainMask).first }
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func save(data: String, name: String) -> URL? {
        do {
            guard let pathLog = pathLog else { return nil }
            let pathFile = pathLog.appendingPathComponent(name)
            try data.write(toFile: pathFile.path, atomically: true, encoding: .utf8)
            return pathFile
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetch() -> AnyPublisher<[URL], Never> {
        guard let pathLog = pathLog,
              let directoryContents = try? fileManager.contentsOfDirectory(at: pathLog,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles])
        else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        return CurrentValueSubject(directoryContents)
            .eraseToAnyPublisher()
    }
    
    func clean() {
        guard let pathLog = pathLog,
              let files = try? fileManager.contentsOfDirectory(atPath: pathLog.path) else { return }
        files.forEach { guard let _ = try? fileManager.removeItem(atPath: $0) else { return } }
    }
    
    
}
